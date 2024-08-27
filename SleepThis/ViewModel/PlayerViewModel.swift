import SwiftUI
import Foundation
import Combine

class PlayerViewModel: ObservableObject {
   @Published var players: [PlayerModel] = []
   @Published var matchups: [MatchupModel] = []
   @Published var isLoading = false
   @Published var errorMessage: String?
   @Published var cacheSize: String?
   @Published var cacheAgeDescription: String?  // Add this property

   let cacheFileName = "cachedPlayers.json"

   init() {
	  print("PlayerViewModel initialized")
	  loadPlayersFromCache()
   }

   func fetchAllPlayers() {
	  print("[fetchAllPlayers:] Starting network fetch for players...")
	  isLoading = true
	  errorMessage = nil

	  let urlString = "https://api.sleeper.app/v1/players/nfl"

	  guard let url = URL(string: urlString) else {
		 self.errorMessage = "Invalid URL"
		 isLoading = false
		 return
	  }

	  URLSession.shared.dataTask(with: url) { data, response, error in
		 DispatchQueue.main.async {
			self.isLoading = false

			if let error = error {
			   self.errorMessage = error.localizedDescription
			   print("[fetchAllPlayers:] Network error: \(error.localizedDescription)")
			   return
			}

			guard let data = data else {
			   self.errorMessage = "No data received"
			   print("[fetchAllPlayers:] No data received from network")
			   return
			}

			do {
			   // Attempt to decode as a dictionary first
			   let playersDictionary = try JSONDecoder().decode([String: PlayerModel].self, from: data)
			   self.players = Array(playersDictionary.values)
			   print("[fetchAllPlayers:] Successfully decoded player data as dictionary")

			   // Check if there's actually data before saving
			   print("[fetchAllPlayers:] Data length before saving: \(data.count) bytes")

			   CacheManager.shared.saveToCache(self.players, as: self.cacheFileName)
			   print("[fetchAllPlayers:] Successfully saved data to cache.")

			   self.cacheSize = self.calculateCacheSize()
			   print("[fetchAllPlayers:] Cache size: \(self.cacheSize ?? "Unknown")")
			} catch {
			   print("[fetchAllPlayers:] Failed to decode player data: \(error)")
			   self.errorMessage = "Failed to decode player data: \(error)"
			}
		 }
	  }.resume()
   }




   // Fetch players based on a lookup query (name or ID)
   func fetchPlayersByLookup(playerLookup: String) {
	  print("Performing player lookup with query: \(playerLookup)")
	  loadPlayersFromCache()

	  if playerLookup.allSatisfy({ $0.isNumber }) {
		 self.players = players.filter { $0.id == playerLookup }
	  } else {
		 let lookupLowercased = playerLookup.lowercased()
		 self.players = players.filter {
			let fullName = "\($0.firstName ?? "") \($0.lastName ?? "")".lowercased()
			return fullName.contains(lookupLowercased)
		 }	  }
	  print("Found \(self.players.count) players matching the query.")
   }

   func getPlayerNames(from ids: [String]) -> String {
	  let matchedPlayers = players.filter { ids.contains($0.id) }
	  return matchedPlayers.compactMap { "\($0.firstName ?? "") \($0.lastName ?? "")" }.joined(separator: ", ")
   }


   func loadPlayersFromCache() {
	  let cacheURL = CacheManager.shared.getCacheDirectory().appendingPathComponent(cacheFileName)
	  print("[loadPlayersFromCache:] Loading players from cache...")

	  // Check if the cache file exists before attempting to load
	  guard FileManager.default.fileExists(atPath: cacheURL.path) else {
		 print("[loadPlayersFromCache:] Cache file does not exist at \(cacheURL.path). \nFetching data from network.")
		 fetchAllPlayers()
		 return
	  }

	  do {
		 let cachedPlayers = try Data(contentsOf: cacheURL)
		 let decodedPlayers = try JSONDecoder().decode([PlayerModel].self, from: cachedPlayers)
		 self.players = decodedPlayers
		 self.cacheSize = calculateCacheSize()
		 print("Loaded \(self.players.count) players from cache.")
	  } catch {
		 print("Failed to load data from cache: \(error.localizedDescription). Fetching data from network as fallback.")
		 fetchAllPlayers() // Fetch from network if loading from cache fails
	  }
   }

   func calculateCacheSize() -> String? {
	  let cacheURL = CacheManager.shared.getCacheDirectory().appendingPathComponent(cacheFileName)
	  if let attributes = try? FileManager.default.attributesOfItem(atPath: cacheURL.path),
		 let fileSize = attributes[.size] as? UInt64 {
		 let fileSizeInMB = Double(fileSize) / (1024 * 1024)
		 print("Cache size: \(fileSizeInMB) MB")
		 return String(format: "%.2f MB", fileSizeInMB)
	  }
	  print("Failed to calculate cache size.")
	  return nil
   }

   func reloadCache() {
	  print("Reloading cache...")
	  fetchAllPlayers()
   }

   func convertHeightToFeetAndInches(heightInches: String) -> String {
	  guard let totalInches = Int(heightInches) else {
		 return "Unknown"
	  }
	  let feet = totalInches / 12
	  let inches = totalInches % 12
	  return "\(feet)'\(inches)\""
   }
}
