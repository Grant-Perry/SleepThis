import Foundation
import Combine
import Observation

@Observable

class NFLRosterViewModel: ObservableObject {
   var players: [NFLRosterModel.NFLPlayer] = []
   var teams: [NFLRosterModel.Team] = []
   var groupedPlayersByTeam: [String: [NFLRosterModel.NFLPlayer]] = [:]

   func fetchPlayersForAllTeams(completion: @escaping () -> Void) {
	  let teamIDs = Array(1...33)
	  let group = DispatchGroup()
	  var allPlayers: [NFLRosterModel.NFLPlayer] = []

	  for teamID in teamIDs {
		 group.enter()
		 let rosterURL = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/teams/\(teamID)/roster")!
		 URLSession.shared.dataTask(with: rosterURL) { data, _, error in
			defer { group.leave() }
			if let error = error {
//			   print("[fetchPlayersForAllTeams:] Failed to fetch roster for team \(teamID): \(error.localizedDescription)")
			   return
			}

			guard let data = data else {
//			   print("[fetchPlayersForAllTeams:] No data received for team \(teamID)")
			   return
			}

			do {
			   var rosterResponse = try JSONDecoder().decode(NFLRosterModel.TeamRosterResponse.self, from: data)
			   NFLRosterModel.applyTeamAndCoachToPlayers(&rosterResponse)
			   let players = rosterResponse.athletes.flatMap { $0.items }

			   // Append players to allPlayers
			   DispatchQueue.main.async {
				  allPlayers.append(contentsOf: players)

				  if !self.teams.contains(where: { $0.id == rosterResponse.team.id }) {
					 self.teams.append(rosterResponse.team) // Add teams from roster response
				  }

//				  print("[fetchPlayersForAllTeams:] Fetched \(players.count) players for team \(teamID).")
			   }
			} catch {
			   print("[fetchPlayersForAllTeams:] Failed to parse roster for team \(teamID): \(error)")
			}
		 }.resume()
	  }

	  group.notify(queue: .main) {
		 self.players = allPlayers
		 self.groupPlayersByTeam()
		 completion()
	  }
   }


   // Group players by team
   func groupPlayersByTeam() {
	  let grouped = Dictionary(grouping: players) { $0.team?.displayName ?? "Unknown Team" }
	  groupedPlayersByTeam = grouped
   }

   // Filtered players based on selected tab
   func filteredPlayers(players: [NFLRosterModel.NFLPlayer], by tab: Int) -> [NFLRosterModel.NFLPlayer] {
	  switch tab {
		 case 1: // Offense
			return players.filter { isOffensivePlayer($0) }
		 case 2: // Defense
			return players.filter { isDefensivePlayer($0) }
		 default: // All
			return players
	  }
   }

   // Helper to check if player is offensive
   func isOffensivePlayer(_ player: NFLRosterModel.NFLPlayer) -> Bool {
	  return ["QB", "RB", "WR", "TE", "OL", "FB"].contains(player.positionAbbreviation)
   }

   // Helper to check if player is defensive
   func isDefensivePlayer(_ player: NFLRosterModel.NFLPlayer) -> Bool {
	  return ["DL", "LB", "CB", "S", "DE", "DT"].contains(player.positionAbbreviation)
   }
}
