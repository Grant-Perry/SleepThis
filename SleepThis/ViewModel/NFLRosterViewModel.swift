import Foundation
import Combine

class NFLRosterViewModel: ObservableObject {
   @Published var players: [NFLRosterModel.NFLPlayer] = []
   @Published var team: NFLRosterModel.Team?
   @Published var coach: NFLRosterModel.Coach?

   func fetchPlayersForAllTeams() {
	  print("[fetchPlayersForAllTeams:] Fetching players for all teams")
	  let teamIDs = Array(1...33)
	  let group = DispatchGroup()
	  var allPlayers: [NFLRosterModel.NFLPlayer] = []

	  for teamID in teamIDs {
		 group.enter()
		 let rosterURL = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/teams/\(teamID)/roster")!
		 URLSession.shared.dataTask(with: rosterURL) { data, _, error in
			defer { group.leave() }
			if let error = error {
			   print("[fetchPlayersForAllTeams:] Failed to fetch roster for team \(teamID): \(error.localizedDescription)")
			   return
			}

			guard let data = data else {
			   print("[fetchPlayersForAllTeams:] No data received for team \(teamID)")
			   return
			}

			do {
			   var rosterResponse = try JSONDecoder().decode(NFLRosterModel.TeamRosterResponse.self, from: data)

			   // Debug print statement to log team info
			   print("[fetchPlayersForAllTeams:] Fetched team info: \(String(describing: rosterResponse.team)) for team ID \(teamID)")

			   let players = rosterResponse.athletes.flatMap { $0.items }

			   // Assign the team and coach to all players
			   for var player in players {
				  // Check if team and coach exist before assigning
					 player.team = rosterResponse.team


				  if let coach = rosterResponse.coach?.coach {
					 player.coach = coach
				  } else if let coachArray = rosterResponse.coach?.coachArray, let firstCoach = coachArray.first {
					 player.coach = firstCoach
				  } else {
					 print("[fetchPlayersForAllTeams:] No coach info for player \(player.fullName) in team ID \(teamID)")
				  }

				  // Append updated player with assigned team and coach
				  allPlayers.append(player)
			   }
			   print("[fetchPlayersForAllTeams:] Fetched \(players.count) players for team \(teamID).")
			} catch {
			   print("[fetchPlayersForAllTeams:] Failed to parse roster for team \(teamID): \(error)")
			}
		 }.resume()
	  }

	  group.notify(queue: .main) {
		 print("[fetchPlayersForAllTeams:] Completed fetching players for all teams.")
		 self.players = allPlayers
	  }
   }
}
