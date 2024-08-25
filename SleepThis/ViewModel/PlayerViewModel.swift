import SwiftUI
import Foundation
import Combine

class PlayerViewModel: ObservableObject {
   @Published var players: [PlayerModel] = []
   @Published var matchups: [MatchupModel] = []
   @Published var isLoading = false
   @Published var errorMessage: String?

   private let cacheDateKey = "playCacheDateKey"
   private let playersCacheKey = "cachedPlayers"

   init() {
	  loadCachedPlayers()
   }

   var cacheAgeDescription: String? {
	  guard let cacheDate = UserDefaults.standard.object(forKey: cacheDateKey) as? Date else {
		 return nil
	  }

	  let calendar = Calendar.current
	  let now = Date()
	  let components = calendar.dateComponents([.day], from: cacheDate, to: now)
	  guard let days = components.day else {
		 return nil
	  }

	  if days == 0 {
		 return "Cache is less than a day old"
	  } else if days == 1 {
		 return "Cache is 1 day old"
	  } else {
		 return "Cache is \(days) days old"
	  }
   }

   var cacheSize: String? {
	  guard let cachedData = UserDefaults.standard.data(forKey: playersCacheKey) else {
		 return nil
	  }
	  let sizeInBytes = Double(cachedData.count)
	  let sizeInMB = sizeInBytes / (1024 * 1024)
	  return String(format: "%.2f MB", sizeInMB)
   }

   func fetchPlayers(playerLookup: String) {
	  isLoading = true
	  errorMessage = nil

	  // Perform the lookup in the cache
	  guard let cachedData = UserDefaults.standard.data(forKey: playersCacheKey) else {
		 self.errorMessage = "No cached data available"
		 self.isLoading = false
		 return
	  }

	  do {
		 let allPlayers = try JSONDecoder().decode([String: PlayerModel].self, from: cachedData)
		 if let player = allPlayers[playerLookup] ?? allPlayers.values.first(where: { $0.fullName?.lowercased().contains(playerLookup.lowercased()) == true }) {
			self.players = [player]
		 } else {
			self.errorMessage = "Player not found in cache"
		 }
	  } catch {
		 self.errorMessage = "Failed to decode cached players: \(error)"
		 print("Failed to decode cached players: \(error)")
	  }

	  self.isLoading = false
   }

   func reloadCache() {
	  fetchAndCachePlayersFromSleeper()
   }

   func loadCachedPlayers() {
	  guard let cachedData = UserDefaults.standard.data(forKey: playersCacheKey) else {
		 errorMessage = "No cached data available"
		 print("No cached data found.")
		 fetchAndCachePlayersFromSleeper()
		 return
	  }

	  do {
		 let players = try JSONDecoder().decode([String: PlayerModel].self, from: cachedData)
		 self.players = Array(players.values)
		 print("Successfully loaded players from cache.")
	  } catch {
		 self.errorMessage = "Failed to decode cached players: \(error)"
		 print("Error decoding cached players: \(error)")
		 // If cache decoding fails, try to reload from the API
		 fetchAndCachePlayersFromSleeper()
	  }
   }

   private func fetchAndCachePlayersFromSleeper() {
	  isLoading = true
	  errorMessage = nil

	  let urlString = "https://api.sleeper.app/v1/players/nfl"
	  guard let url = URL(string: urlString) else {
		 self.errorMessage = "Invalid URL"
		 print("Invalid URL: \(urlString)")
		 return
	  }

	  URLSession.shared.dataTask(with: url) { data, response, error in
		 DispatchQueue.main.async {
			self.isLoading = false

			if let error = error {
			   self.errorMessage = error.localizedDescription
			   print("Error fetching data from Sleeper: \(error.localizedDescription)")
			   return
			}

			guard let data = data else {
			   self.errorMessage = "No data received"
			   print("No data received from Sleeper API.")
			   return
			}

			do {
			   let players = try JSONDecoder().decode([String: PlayerModel].self, from: data)
			   self.players = Array(players.values)
			   self.savePlayersToCache(data)
			   print("Successfully fetched and cached players from Sleeper API.")
			} catch {
			   self.errorMessage = "Failed to decode player data: \(error)"
			   print("Failed to decode player data: \(error)")
			}
		 }
	  }.resume()
   }

   private func savePlayersToCache(_ data: Data) {
	  let defaults = UserDefaults.standard
	  defaults.set(data, forKey: playersCacheKey)
	  defaults.set(Date(), forKey: cacheDateKey)
	  print("Players data saved to cache successfully.")
   }

   func fetchMatchups(leagueID: String, week: Int) {
	  isLoading = true

	  let urlString = "https://api.sleeper.app/v1/league/\(leagueID)/matchups/\(week)"
	  guard let url = URL(string: urlString) else {
		 self.errorMessage = "Invalid URL"
		 print("Invalid URL: \(urlString)")
		 return
	  }

	  URLSession.shared.dataTask(with: url) { data, response, error in
		 DispatchQueue.main.async {
			self.isLoading = false

			if let error = error {
			   self.errorMessage = error.localizedDescription
			   print("Error fetching matchups: \(error.localizedDescription)")
			   return
			}

			guard let data = data else {
			   self.errorMessage = "No data received"
			   print("No data received for matchups.")
			   return
			}

			do {
			   let matchups = try JSONDecoder().decode([MatchupModel].self, from: data)
			   self.matchups = matchups
			   self.saveMatchupsToCache(matchups: matchups)
			   print("Successfully fetched and cached matchups.")
			} catch {
			   self.errorMessage = "Failed to decode matchup data: \(error)"
			   print("Failed to decode matchup data: \(error)")
			}
		 }
	  }.resume()
   }

   func saveMatchupsToCache(matchups: [MatchupModel]) {
	  // Implement cache saving logic for matchups if needed
	  print("Matchups data saved to cache (implement saving logic).")
   }

   func convertHeightToFeetAndInches(height: String?) -> String {
	  guard let heightInInches = Int(height ?? "") else {
		 return "Unknown"
	  }

	  let feet = heightInInches / 12
	  let inches = heightInInches % 12
	  return "\(feet)'\(inches)\""
   }

   func getPlayerNames(from ids: [String]) -> String {
	  return ids.compactMap { id in
		 players.first(where: { $0.id == id })?.fullName
	  }.joined(separator: ", ")
   }
}
