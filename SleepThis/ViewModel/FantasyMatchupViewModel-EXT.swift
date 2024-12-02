import SwiftUI

extension FantasyMatchupViewModel {

   func fetchFantasyData(forWeek week: Int) {
	  print("DP - Fetching fantasy data for league ID: \(leagueID), week: \(week)")

	  // Remove the guard statement that checks for a specific leagueID
	  guard let url = URL(string: "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/\(selectedYear)/segments/0/leagues/\(leagueID)?view=mMatchupScore&view=mLiveScoring&view=mRoster&view=mStats&scoringPeriodId=\(week)") else {
		 print("DP - Invalid URL for ESPN data fetch.")

		 isLoading = false

		 return

	  }

	  var request = URLRequest(url: url)

	  request.addValue("application/json", forHTTPHeaderField: "Accept")

	  request.addValue("SWID=\(AppConstants.SWID); espn_s2=\(AppConstants.ESPN_S2)", forHTTPHeaderField: "Cookie")

	  print("DP - Sending request to ESPN API: \(url)")

	  URLSession.shared.dataTaskPublisher(for: request)

		 .map { $0.data }

		 .decode(type: FantasyScores.FantasyModel.self, decoder: JSONDecoder())

		 .receive(on: DispatchQueue.main)

		 .sink(receiveCompletion: { [weak self] completion in

			self?.isLoading = false

			if case .failure(let error) = completion {

			   print("DP - Error fetching ESPN data: \(error)")

			   self?.errorMessage = "Error fetching ESPN data: \(error.localizedDescription)"

			}

		 }, receiveValue: { [weak self] model in

			guard let self = self else { return }

			print("DP - Received ESPN data successfully")

			self.fantasyModel = model

			print("DP - Number of teams: \(model.teams.count)")

			print("DP - Number of schedules: \(model.schedule.count)")

			self.processESPNMatchups(model: model)

			self.isLoading = false

		 })

		 .store(in: &cancellables)

   }

   // Update the processESPNMatchups function
   func processESPNMatchups(model: FantasyScores.FantasyModel) {
	  print("DP - Processing ESPN matchups")

	  var processedMatchups: [AnyFantasyMatchup] = []
	  for matchup in model.schedule.filter({ $0.matchupPeriodId == selectedWeek }) {
		 let awayTeamId = matchup.away.teamId
		 let homeTeamId = matchup.home.teamId
		 let awayTeam = model.teams.first { $0.id == awayTeamId }
		 let homeTeam = model.teams.first { $0.id == homeTeamId }
		 print("DP - Processing matchup: Away Team ID: \(awayTeamId), Home Team ID: \(homeTeamId)")
		 let awayTeamName = awayTeam?.name ?? "Unknown"
		 let homeTeamName = homeTeam?.name ?? "Unknown"

		 // Create FantasyMatchup with consistent visitor/home designation

		 let awayAvatarURL = getESPNAvatarURL(for: awayTeamId)
		 let homeAvatarURL = getESPNAvatarURL(for: homeTeamId)
		 print("DP - Away avatar URL: \(awayAvatarURL?.absoluteString ?? "N/A")")
		 print("DP - Home avatar URL: \(homeAvatarURL?.absoluteString ?? "N/A")")

		 let fantasyMatchup = FantasyScores.FantasyMatchup(
			homeTeamName: homeTeamName,
			awayTeamName: awayTeamName,
			homeScore: calculateESPNTeamActiveScore(team: homeTeam, week: selectedWeek),
			awayScore: calculateESPNTeamActiveScore(team: awayTeam, week: selectedWeek),
			homeAvatarURL: homeAvatarURL,
			awayAvatarURL: awayAvatarURL,
			homeManagerName: homeTeamName,
			awayManagerName: awayTeamName,
			homeTeamID: homeTeamId,
			awayTeamID: awayTeamId
		 )
		 processedMatchups.append(AnyFantasyMatchup(fantasyMatchup))

		 // Add the debug call here
		 self.debugESPNRosters()
	  }

	  // Process player stats first
	  processPlayerStats(from: model)

	  // Update matchups on the main thread

	  DispatchQueue.main.async {

		 self.matchups = processedMatchups

		 print("DP - Processed \(processedMatchups.count) ESPN matchups")

		 self.objectWillChange.send()

	  }

   }

   func getRoster(for matchup: AnyFantasyMatchup, teamIndex: Int, isBench: Bool) -> [FantasyScores.FantasyModel.Team.PlayerEntry] {
	  if leagueID == AppConstants.ESPNLeagueID[1] {
		 // ESPN league
		 let teamId = teamIndex == 0 ? matchup.awayTeamID : matchup.homeTeamID
		 // Add debug print
		 print("DP - Getting roster for ESPN league: \(leagueID) for team ID: \(teamId)")
		 guard let team = fantasyModel?.teams.first(where: { $0.id == teamId }) else {
			print("DP - Error: Team not found for ID \(teamId) in ESPN league \(leagueID)")
			// Return an empty array instead of fatalError
			return []
		 }
		 let activeSlotsOrder: [Int] = [0, 2, 3, 4, 5, 6, 23, 16, 17]
		 return team.roster?.entries.filter { entry in
			isBench ? !activeSlotsOrder.contains(entry.lineupSlotId) : activeSlotsOrder.contains(entry.lineupSlotId)
		 } ?? []
	  } else {
		 // Sleeper league
		 let sleeperMatchup = teamIndex == 0 ? matchup.sleeperData?.0 : matchup.sleeperData?.1
		 guard let playerIds = isBench ? sleeperMatchup?.players : sleeperMatchup?.starters else {
			print("DP - Error: No \(isBench ? "bench" : "starter") players found for Sleeper matchup")
			return []
		 }
		 return playerIds.compactMap { createPlayerEntry(from: $0) }
	  }
   }

   // Add this function to create a default player entry when a player is not found
   func createDefaultPlayerEntry(playerId: String) -> FantasyScores.FantasyModel.Team.PlayerEntry {
	  return FantasyScores.FantasyModel.Team.PlayerEntry(
		 playerPoolEntry: .init(
			player: .init(
			   id: Int(playerId) ?? 0,
			   fullName: "Unknown Player",
			   stats: []
			)
		 ),
		 lineupSlotId: 23 // Default to FLEX
	  )
   }


   func debugESPNRosters() {
	  guard let model = fantasyModel else {
		 print("DP - Error: No fantasy model available")
		 return
	  }

	  print("DP - Debugging ESPN Rosters:")
	  for team in model.teams {
		 print("DP - Team: \(team.name)")
		 print("DP - Roster entries count: \(team.roster?.entries.count ?? 0)")
		 team.roster?.entries.forEach { entry in
			print("DP - Player: \(entry.playerPoolEntry.player.fullName), Position: \(positionString(entry.lineupSlotId))")
		 }
		 print("---")
	  }
   }

   // Add this helper function to get a default player image URL
   private func getDefaultPlayerImageURL() -> String {
	  // Replace this with your actual default player image URL
	  return "https://example.com/default-player-image.png"
   }

   private func processPlayerStats(from model: FantasyScores.FantasyModel) {
	  playerStats.removeAll()

	  for team in model.teams {
		 guard let roster = team.roster else { continue }

		 for entry in roster.entries {
			let playerId = String(entry.playerPoolEntry.player.id)
			let playerStats = entry.playerPoolEntry.player.stats.reduce(into: [String: Double]()) { result, stat in
			   // Check if the stat is for the current week
			   if stat.scoringPeriodId == selectedWeek && stat.statSourceId == 0 {
				  // Instead of trying to access 'stats', we'll use the 'appliedTotal'
				  result["total"] = stat.appliedTotal ?? 0.0
				  // You can add more specific stats here if needed
			   }
			}
			self.playerStats[playerId] = playerStats
		 }
	  }

	  print("DP - Processed stats for \(playerStats.count) players")
   }
}

// Add this function to get ESPN avatar URLs
func getESPNAvatarURL(for teamId: Int) -> URL? {
   // ESPN avatar URL format
   return URL(string: "https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/\(teamId).png")
}
