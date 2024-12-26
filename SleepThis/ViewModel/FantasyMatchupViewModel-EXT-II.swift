import SwiftUI

// Extension for FantasyMatchupViewModel to handle manager records
extension FantasyMatchupViewModel {
   
   
   func getManagerRecord(managerID: String) -> String {
	  print("DP - Getting record for managerID: \(managerID)")
	  print("DP - Current managerRecords: \(managerRecords)")
	  
	  // Convert rosterID to ownerID if needed
	  let ownerID = rosterIDToManagerID[Int(managerID) ?? 0] ?? managerID
	  print("DP - Looking up record for ownerID: \(ownerID)")
	  
	  if let record = managerRecords[ownerID] {
		 print("DP - Found record: \(record.wins)-\(record.losses)-\(record.ties)")
		 let rankText = managerRanks[ownerID].map { " #\($0)" } ?? ""
		 let recordText = record.ties > 0 ?
		 "\(record.wins)-\(record.losses)-\(record.ties)" :
		 "\(record.wins)-\(record.losses)"
		 return "\(rankText) with \(recordText)"
	  }
	  print("DP - No record found for ownerID: \(ownerID)")
	  return "0-0"
   }
   
   // Helper method to fetch users after rosters
   func fetchSleeperUsers(completion: @escaping () -> Void) {
	  guard let usersURL = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)/users") else {
		 print("DP - Invalid users URL")
		 completion()
		 return
	  }
	  
	  URLSession.shared.dataTask(with: usersURL) { [weak self] data, response, error in
		 // Rest of your existing user fetch code...
		 if let error = error {
			print("DP - Error fetching users: \(error)")
			completion()
			return
		 }
		 
		 guard let data = data else {
			print("DP - No user data received")
			completion()
			return
		 }
		 
		 do {
			let users = try JSONDecoder().decode([SleeperUser].self, from: data)
			print("DP - Successfully fetched \(users.count) users")
			
			DispatchQueue.main.async {
			   for user in users {
				  self?.userIDs[user.user_id] = user.display_name
				  if let avatar = user.avatar {
					 self?.userAvatars[user.user_id] = URL(string: "https://sleepercdn.com/avatars/\(avatar)")
				  }
			   }
			   completion()
			}
		 } catch {
			print("DP - Error decoding users: \(error)")
			completion()
		 }
	  }.resume()
   }
   
   func processSleeperRosters(_ rosters: [SleeperRoster]) {
	  // Sort rosters by wins for ranking
	  let sortedRosters = rosters.sorted { ($0.settings?.wins ?? 0) > ($1.settings?.wins ?? 0) }
	  
	  // Sort by points for PF ranking
	  let sortedByPF = rosters.sorted {
		 (($0.settings?.fpts ?? 0) + ($0.settings?.fpts_decimal ?? 0)/100) >
		 (($1.settings?.fpts ?? 0) + ($1.settings?.fpts_decimal ?? 0)/100)
	  }
	  
	  // Sort by points against for PA ranking
	  let sortedByPA = rosters.sorted {
		 (($0.settings?.fpts_against ?? 0) + ($0.settings?.fpts_against_decimal ?? 0)/100) >
		 (($1.settings?.fpts_against ?? 0) + ($1.settings?.fpts_against_decimal ?? 0)/100)
	  }
	  
	  // Process each roster
	  for roster in rosters {
		 guard let settings = roster.settings else { continue }
		 
		 let rank = (sortedRosters.firstIndex(where: { $0.roster_id == roster.roster_id }) ?? 0) + 1
		 let pfRank = (sortedByPF.firstIndex(where: { $0.roster_id == roster.roster_id }) ?? 0) + 1
		 let paRank = (sortedByPA.firstIndex(where: { $0.roster_id == roster.roster_id }) ?? 0) + 1
		 
		 let totalPF = Double(settings.fpts ?? 0) + Double(settings.fpts_decimal ?? 0)/100
		 let totalPA = Double(settings.fpts_against ?? 0) + Double(settings.fpts_against_decimal ?? 0)/100
		 
		 let record = TeamRecord(
			wins: settings.wins,
			losses: settings.losses,
			rank: rank,
			pfRank: pfRank,
			paRank: paRank,
			totalPF: totalPF,
			totalPA: totalPA
		 )
		 
		 sleeperTeamRecords[roster.roster_id] = record
	  }
   }
   
   
   // Update the processSleeperMatchups function
   func processSleeperMatchups(_ sleeperMatchups: [FantasyScores.SleeperMatchup]) {
	  let groupedMatchups = Dictionary(grouping: sleeperMatchups, by: { $0.matchup_id })
	  var processedMatchups: [AnyFantasyMatchup] = []
	  
	  for (_, matchups) in groupedMatchups where matchups.count == 2 {
		 let team1 = matchups[0]
		 let team2 = matchups[1]
		 
		 // Swap the home/away designation to match ESPN's convention
		 // team1 is now away, team2 is home (opposite of before)
		 let awayManagerID = rosterIDToManagerID[team1.roster_id] ?? ""
		 let homeManagerID = rosterIDToManagerID[team2.roster_id] ?? ""
		 
		 // Get manager names from userIDs dictionary
		 let awayManagerName = userIDs[awayManagerID] ?? "Unknown Manager"
		 let homeManagerName = userIDs[homeManagerID] ?? "Unknown Manager"
		 
		 let awayAvatarURL = userAvatars[awayManagerID]
		 let homeAvatarURL = userAvatars[homeManagerID]
		 
		 let awayScore = calculateSleeperTeamScore(matchup: team1)
		 let homeScore = calculateSleeperTeamScore(matchup: team2)
		 
		 let awayRecord = getManagerRecord(managerID: awayManagerID)
		 let homeRecord = getManagerRecord(managerID: homeManagerID)
		 
		 let fantasyMatchup = FantasyScores.FantasyMatchup(
			homeTeamName: homeManagerName,
			awayTeamName: awayManagerName,
			homeScore: homeScore,
			awayScore: awayScore,
			homeAvatarURL: homeAvatarURL,
			awayAvatarURL: awayAvatarURL,
			homeManagerName: homeManagerName,
			awayManagerName: awayManagerName,
			homeTeamID: team2.roster_id,  // Swapped team IDs
			awayTeamID: team1.roster_id
		 )
		 
		 processedMatchups.append(AnyFantasyMatchup(fantasyMatchup, sleeperData: (team1, team2)))
	  }
	  
	  DispatchQueue.main.async {
		 self.matchups = processedMatchups
	  }
   }
   
   func fetchSleeperLeagueUsersAndRosters(completion: @escaping () -> Void) {
	  print("DP - Starting roster fetch for league: \(leagueID)")
	  
	  guard let rostersURL = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)/rosters") else {
		 completion()
		 return
	  }
	  
	  URLSession.shared.dataTask(with: rostersURL) { [weak self] data, response, error in
		 if let error = error {
			print("DP - Error fetching rosters: \(error)")
			completion()
			return
		 }
		 
		 guard let data = data else {
			print("DP - No roster data received")
			completion()
			return
		 }
		 
		 do {
			let rosters = try JSONDecoder().decode([SleeperRoster].self, from: data)
			print("DP - Successfully decoded \(rosters.count) rosters")
			
			// Sort rosters by wins for ranking
			let sortedRosters = rosters.sorted {
			   ($0.settings?.wins ?? 0) > ($1.settings?.wins ?? 0)
			}
			
			// Sort by points for PF ranking
			let sortedByPF = rosters.sorted {
			   (($0.settings?.fpts ?? 0) + ($0.settings?.fpts_decimal ?? 0)/100) >
			   (($1.settings?.fpts ?? 0) + ($1.settings?.fpts_decimal ?? 0)/100)
			}
			
			// Sort by points against for PA ranking
			let sortedByPA = rosters.sorted {
			   (($0.settings?.fpts_against ?? 0) + ($0.settings?.fpts_against_decimal ?? 0)/100) >
			   (($1.settings?.fpts_against ?? 0) + ($1.settings?.fpts_against_decimal ?? 0)/100)
			}
			
			DispatchQueue.main.async {
			   // Process rosters and rankings
			   for (index, roster) in sortedRosters.enumerated() {
				  if let ownerID = roster.owner_id,
					 let settings = roster.settings {
					 // Store basic record
					 self?.managerRecords[ownerID] = (
						wins: settings.wins,
						losses: settings.losses,
						ties: settings.ties
					 )
					 
					 // Store rank (1-based index)
					 self?.managerRanks[ownerID] = index + 1
					 
					 // Store roster ID mapping
					 self?.rosterIDToManagerID[roster.roster_id] = ownerID
					 
					 // Calculate and store detailed team record
					 let pfRank = (sortedByPF.firstIndex(where: { $0.roster_id == roster.roster_id }) ?? 0) + 1
					 let paRank = (sortedByPA.firstIndex(where: { $0.roster_id == roster.roster_id }) ?? 0) + 1
					 let totalPF = Double(settings.fpts ?? 0) + Double(settings.fpts_decimal ?? 0)/100
					 let totalPA = Double(settings.fpts_against ?? 0) + Double(settings.fpts_against_decimal ?? 0)/100
					 
					 let record = TeamRecord(
						wins: settings.wins,
						losses: settings.losses,
						rank: index + 1,
						pfRank: pfRank,
						paRank: paRank,
						totalPF: totalPF,
						totalPA: totalPA
					 )
					 
					 // Store the team record using roster_id
					 self?.sleeperTeamRecords[roster.roster_id] = record
				  }
			   }
			   
			   // Now proceed with user data fetch
			   self?.fetchSleeperUsers(completion: completion)
			}
		 } catch {
			print("DP - Error decoding rosters: \(error)")
			completion()
		 }
	  }.resume()
   }
   
   func fetchESPNRecords(forWeek week: Int) {
	  // Basic URL with just mTeam view to get minimal data needed
	  guard let url = URL(string: "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/\(selectedYear)/segments/0/leagues/\(leagueID)?view=mTeam") else {
		 print("DP - Error: Unable to create URL")
		 return
	  }
	  
	  var request = URLRequest(url: url)
	  request.addValue("application/json", forHTTPHeaderField: "Accept")
	  request.addValue("SWID=\(AppConstants.SWID); espn_s2=\(AppConstants.ESPN_S2)", forHTTPHeaderField: "Cookie")
	  
	  print("DP - Fetching ESPN records")
	  
	  URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
		 guard let self = self else { return }
		 
		 if let data = data {
			do {
			   let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
			   
			   if let teams = json?["teams"] as? [[String: Any]] {
				  for team in teams {
					 if let teamId = team["id"] as? Int,
						let record = team["record"] as? [String: Any],
						let overall = record["overall"] as? [String: Any],
						let wins = overall["wins"] as? Int,
						let losses = overall["losses"] as? Int {
						
						print("DP - Found ESPN record for team \(teamId): \(wins)-\(losses)")
						DispatchQueue.main.async {
						   self.managerRecords[String(teamId)] = (wins: wins, losses: losses, ties: 0)
						}
					 }
				  }
			   }
			} catch {
			   print("DP - Error parsing ESPN records: \(error)")
			}
		 }
	  }.resume()
   }
   
}
