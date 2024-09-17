import Foundation
import Combine

class NFLRosterViewModel: ObservableObject {
   @Published var players: [NFLRosterModel.NFLPlayer] = []
   private let cacheFileName = "nfl_roster_cache.json"

   init() {
	  print("[NFLRosterViewModel:init] Loading cache or fetching players if needed.")
	  loadCacheOrFetch()
   }

   func extractPlayerId(from uid: String) -> String {
	  if let lastPart = uid.split(separator: ":").last {
		 return String(lastPart)
	  }
	  return uid // Return the original string if we can't extract the ID
   }

   func getPlayerImageURL(for player: NFLRosterModel.NFLPlayer) -> URL? {
	  let playerId = extractPlayerId(from: player.uid)
	  return URL(string: "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/\(playerId).png")
   }

   func fetchPlayersForAllTeams() {
	  print("[fetchPlayersForAllTeams:] Fetching players for all teams")
	  let teamIDs = Array(1...33) // 33 teams
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
			   print("[fetchPlayersForAllTeams:] Fetched \(players.count) players for team \(teamID).")
			   allPlayers.append(contentsOf: players)
			} catch {
			   print("[fetchPlayersForAllTeams:] Failed to parse roster for team \(teamID): \(error)")
			}
		 }.resume()
	  }

	  group.notify(queue: .main) {
		 print("[fetchPlayersForAllTeams:] Completed fetching players for all teams.")
		 self.players = allPlayers
		 self.saveCache()
	  }
   }

   private func saveCache() {
	  let cacheURL = getCacheURL()
	  do {
		 let data = try JSONEncoder().encode(players)
		 try data.write(to: cacheURL)
		 print("[saveCache:] Cache saved successfully!")
	  } catch {
		 print("[saveCache:] Failed to save cache: \(error)")
	  }
   }

   private func loadCacheOrFetch() {
	  let cacheURL = getCacheURL()
	  if FileManager.default.fileExists(atPath: cacheURL.path) {
		 do {
			let data = try Data(contentsOf: cacheURL)
			players = try JSONDecoder().decode([NFLRosterModel.NFLPlayer].self, from: data)
			print("[loadCacheOrFetch:] Loaded data from cache. Number of players: \(players.count)")
			if players.isEmpty {
			   print("[loadCacheOrFetch:] Cache is empty, fetching from API.")
			   fetchPlayersForAllTeams()
			}
		 } catch {
			print("[loadCacheOrFetch:] Failed to load cache: \(error). Fetching from API.")
			fetchPlayersForAllTeams()
		 }
	  } else {
		 print("[loadCacheOrFetch:] No cache found. Fetching from API.")
		 fetchPlayersForAllTeams()
	  }
   }

   private func getCacheURL() -> URL {
	  let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	  return documentDirectory.appendingPathComponent(cacheFileName)
   }
}
