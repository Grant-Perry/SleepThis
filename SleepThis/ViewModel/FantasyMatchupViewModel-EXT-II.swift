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

   // Update the processSleeperMatchups function
   func processSleeperMatchups(_ sleeperMatchups: [FantasyScores.SleeperMatchup]) {
	  let groupedMatchups = Dictionary(grouping: sleeperMatchups, by: { $0.matchup_id })
	  var processedMatchups: [AnyFantasyMatchup] = []

	  for (_, matchups) in groupedMatchups where matchups.count == 2 {
		 let team1 = matchups[0]
		 let team2 = matchups[1]

		 // Get manager IDs first
		 let homeManagerID = rosterIDToManagerID[team1.roster_id] ?? ""
		 let awayManagerID = rosterIDToManagerID[team2.roster_id] ?? ""

		 // Get manager names from userIDs dictionary
		 let homeManagerName = userIDs[homeManagerID] ?? "Unknown Manager"
		 let awayManagerName = userIDs[awayManagerID] ?? "Unknown Manager"

		 let homeAvatarURL = userAvatars[homeManagerID]
		 let awayAvatarURL = userAvatars[awayManagerID]

		 let homeScore = calculateSleeperTeamScore(matchup: team1)
		 let awayScore = calculateSleeperTeamScore(matchup: team2)

		 let homeRecord = getManagerRecord(managerID: homeManagerID)
		 let awayRecord = getManagerRecord(managerID: awayManagerID)

		 let fantasyMatchup = FantasyScores.FantasyMatchup(
			homeTeamName: homeManagerName,
			awayTeamName: awayManagerName,
			homeScore: homeScore,
			awayScore: awayScore,
			homeAvatarURL: homeAvatarURL,
			awayAvatarURL: awayAvatarURL,
			homeManagerName: homeManagerName,
			awayManagerName: awayManagerName,
			homeTeamID: team1.roster_id,
			awayTeamID: team2.roster_id
		 )

		 processedMatchups.append(AnyFantasyMatchup(fantasyMatchup, sleeperData: (team1, team2)))
	  }

	  DispatchQueue.main.async {
		 self.matchups = processedMatchups
	  }
   }



}
