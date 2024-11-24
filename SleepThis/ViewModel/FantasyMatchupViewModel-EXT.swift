//   FantasyMatchupViewModel-EXT.swift
//   SleepThis
//
//   Created by: Gp. on 11/24/24 at 10:24 AM
//     Modified:
//
//  Copyright  2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI

extension FantasyMatchupViewModel {

   func fetchFantasyData(forWeek week: Int) {
	  print("DP - Fetching fantasy data for league ID: \(leagueID), week: \(week)")

	  // Remove the guard statement that checks for a specific leagueID
	  guard let url = URL(string: "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/\(selectedYear)/segments/0/leagues/\(leagueID)?view=mMatchupScore&view=mLiveScoring&view=mRoster&scoringPeriodId=\(week)") else {
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

		 let fantasyMatchup = FantasyScores.FantasyMatchup(
			homeTeamName: homeTeamName,
			awayTeamName: awayTeamName,
			homeScore: calculateESPNTeamActiveScore(team: homeTeam, week: selectedWeek),
			awayScore: calculateESPNTeamActiveScore(team: awayTeam, week: selectedWeek),
			homeAvatarURL: nil,
			awayAvatarURL: nil,
			homeManagerName: homeTeamName,
			awayManagerName: awayTeamName,
			homeTeamID: homeTeamId,
			awayTeamID: awayTeamId
		 )
		 processedMatchups.append(AnyFantasyMatchup(fantasyMatchup))

		 // Add the debug call here
		 self.debugESPNRosters()
	  }

	  // Update matchups on the main thread

	  DispatchQueue.main.async {

		 self.matchups = processedMatchups

		 print("DP - Processed \(processedMatchups.count) ESPN matchups")

		 self.objectWillChange.send()

	  }

   }

   func getRoster(for matchup: AnyFantasyMatchup, teamIndex: Int, isBench: Bool) -> [FantasyScores.FantasyModel.Team.PlayerEntry] {
	  // teamIndex 0 is always visitor/away, 1 is always home
	  if leagueID.starts(with: "1") { // Check if it's an ESPN league (assuming ESPN league IDs start with 1)
		 print("DP - Getting roster for ESPN league: \(leagueID)")
		 let teamId = teamIndex == 0 ? matchup.awayTeamID : matchup.homeTeamID
		 guard let team = fantasyModel?.teams.first(where: { $0.id == teamId }) else {
			print("DP - Error: Team not found for ID \(teamId)")
			return []
		 }

		 let activeSlotsOrder: [Int] = [0, 2, 3, 4, 5, 6, 23, 16, 17]
		 let benchSlots = Array(20...30)
		 let relevantSlots = isBench ? benchSlots : activeSlotsOrder

		 print("DP - Team \(team.name) roster entries count: \(team.roster?.entries.count ?? 0)")

		 // Return the filtered and sorted roster entries
		 return team.roster?.entries
			.filter { relevantSlots.contains($0.lineupSlotId) }
			.sorted { player1, player2 in
			   let index1 = relevantSlots.firstIndex(of: player1.lineupSlotId) ?? Int.max
			   let index2 = relevantSlots.firstIndex(of: player2.lineupSlotId) ?? Int.max
			   return index1 < index2
			} ?? []
	  } else {
		 // Existing Sleeper logic
		 guard let sleeperMatchupData = matchup.sleeperData else { return [] }
		 let sleeperMatchup = teamIndex == 0 ? sleeperMatchupData.0 : sleeperMatchupData.1

		 let playerIds = isBench ?
		 (sleeperMatchup.players?.filter { !(sleeperMatchup.starters?.contains($0) ?? false) } ?? []) :
		 (sleeperMatchup.starters ?? [])

		 return playerIds.map { playerId in
			createPlayerEntry(from: playerId)
		 }
	  }
   }

   // Add this function to debug ESPN rosters
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

}
