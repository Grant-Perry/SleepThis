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
			   let rosterResponse = try JSONDecoder().decode(NFLRosterModel.TeamRosterResponse.self, from: data)
			   let players = rosterResponse.athletes.flatMap { $0.items }

			   // Handle multiple coaches or single coach
			   let coach = rosterResponse.coach?.coach ?? rosterResponse.coach?.coachArray?.first
			   for var player in players {
				  player.team = rosterResponse.team
				  player.coach = coach

				  // Print out the player's image URL for debugging
				  if let imageUrl = player.imageUrl {
					 print("[Player Image URL] \(player.fullName): \(imageUrl.absoluteString)")
				  } else {
					 print("[Player Image URL] \(player.fullName): No valid image URL")
				  }
			   }
			   allPlayers.append(contentsOf: players)
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
