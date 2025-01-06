import Foundation

@MainActor
class NFLScheduleViewModel: ObservableObject {
   @Published var games: [NFLScheduleGame] = []
   private var teamToGameMap: [String: NFLScheduleGame] = [:]

   init() {
	  fetchNFLSchedule()
   }

   func fetchNFLSchedule() {
	  guard let url = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard") else {
		 print("Invalid NFL scoreboard URL.")
		 return
	  }

	  Task {
		 do {
			let (data, _) = try await URLSession.shared.data(from: url)
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let response = try decoder.decode(NFLScheduleResponse.self, from: data)

			var fetchedGames: [NFLScheduleGame] = []

			for event in response.events {
			   guard let competition = event.competitions.first else { continue }

			   let dateFormatter = ISO8601DateFormatter()
			   guard let gameDate = dateFormatter.date(from: event.date) else { continue }

			   // Determine status
			   let statusName = competition.status.type.name
			   let status: NFLScheduleGame.GameStatus
			   switch statusName {
				  case "STATUS_IN_PROGRESS", "STATUS_HALFTIME":
					 status = .inProgress
				  case "STATUS_FINAL", "STATUS_POSTPONED", "STATUS_END_OF_PERIOD":
					 status = .final
				  default:
					 status = .scheduled
			   }

			   // Extract teams
			   let competitors = competition.competitors
			   guard competitors.count == 2 else { continue }

			   let homeTeamComp = competitors.first(where: { $0.homeAway == "home" })
			   let awayTeamComp = competitors.first(where: { $0.homeAway == "away" })

			   guard let homeTeam = homeTeamComp?.team.displayName,
					 let awayTeam = awayTeamComp?.team.displayName,
					 let homeAbb = homeTeamComp?.team.abbreviation,
					 let awayAbb = awayTeamComp?.team.abbreviation
			   else { continue }

			   let homeScore = Int(homeTeamComp?.score ?? "")
			   let awayScore = Int(awayTeamComp?.score ?? "")

			   // Format day of week and display time
			   let dateFormatter2 = DateFormatter()
			   dateFormatter2.dateFormat = "EEEE"
			   let dayOfWeek = dateFormatter2.string(from: gameDate)

			   let timeFormatter = DateFormatter()
			   timeFormatter.dateFormat = "h:mm a" // e.g., "4:25 PM"
			   let displayTime = timeFormatter.string(from: gameDate)

			   let game = NFLScheduleGame(
				  homeTeam: homeTeam,
				  awayTeam: awayTeam,
				  homeAbbrev: homeAbb,
				  awayAbbrev: awayAbb,
				  homeScore: homeScore,
				  awayScore: awayScore,
				  startTime: gameDate,
				  dayOfWeek: dayOfWeek,
				  displayTime: displayTime,
				  status: status
			   )

			   fetchedGames.append(game)
			}

			self.games = fetchedGames
			self.createTeamToGameMap()

		 } catch {
			print("Error fetching NFL schedule: \(error)")
		 }
	  }
   }

   private func createTeamToGameMap() {
	  // Map each team abbreviation to its game for easy lookup
	  teamToGameMap.removeAll()
	  for game in games {
		 teamToGameMap[game.homeAbbrev.uppercased()] = game
		 teamToGameMap[game.awayAbbrev.uppercased()] = game
	  }
   }

   /// Returns the matchup for the given team abbreviation (e.g. "KC", "BUF", "PHI"), or nil if not found
   func getTeamMatchup(for teamAbbrev: String) -> NFLScheduleGame? {
	  return teamToGameMap[teamAbbrev.uppercased()]
   }
}
