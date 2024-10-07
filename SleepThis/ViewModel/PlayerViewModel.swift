import SwiftUI
import Foundation
import Combine
import Observation

@Observable

class PlayerViewModel: ObservableObject {
   var players: [PlayerModel] = []
   var isLoading = false
   var errorMessage: String?
   var cacheSize: String?
   var cacheAgeDescription: String?

   private var maxCacheDays = AppConstants.maxCacheDays
   let cacheFileName = "cachedPlayers.json"

   init() {
	  loadPlayersFromCache()
   }

   func getPlayerInfo(by id: String) -> PlayerModel? {
	  return players.first(where: { $0.id == id })
   }

   func getPlayerNames(from ids: [String]) -> String {
	  let matchedPlayers = players.filter { ids.contains($0.id) }
	  return matchedPlayers.compactMap { "\($0.firstName ?? "") \($0.lastName ?? "")" }.joined(separator: ", ")
   }

   // Fetch player details by ID
   func fetchPlayerDetails(playerID: String, completion: @escaping (PlayerModel?) -> Void) {
	  if let player = players.first(where: { $0.id == playerID }) {
		 completion(player)
	  } else {
		 errorMessage = "Player not found."
		 completion(nil)
	  }
   }

   // Fetch all players from the API and filter
   func fetchAllPlayers() {
	  // Construct the URL for the API endpoint
	  guard let url = URL(string: "https://api.sleeper.app/v1/players/nfl") else {
		 print("[fetchAllPlayers]: Invalid URL.")
		 return
	  }

	  // Create a URLSession data task to fetch data from the API
	  URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
		 // Handle errors from the network request
		 if let error = error {
			print("[fetchAllPlayers]: Network request failed with error: \(error.localizedDescription)")
			return
		 }

		 // Ensure data is not nil
		 guard let data = data else {
			print("[fetchAllPlayers]: No data received from the network.")
			return
		 }

		 do {
			// Decode the JSON data into a dictionary of PlayerModel objects
			let decoder = JSONDecoder()
			let playerDictionary = try decoder.decode([String: PlayerModel].self, from: data)

			// Convert the dictionary values into an array
			let playerArray = Array(playerDictionary.values)

			// Sort the players if needed (e.g., by name)
			let sortedPlayers = playerArray.sorted { (player1: PlayerModel, player2: PlayerModel) -> Bool in
			   let name1 = player1.fullName ?? ""
			   let name2 = player2.fullName ?? ""
			   return name1 < name2
			}


			// Calculate cache size and age on a background thread
			DispatchQueue.global(qos: .background).async {
			   let cacheSize = self?.calculateCacheSize()
			   let cacheAgeDescription = "Cache Age: 0 day(s)" // Since we just fetched fresh data

			   // Save data to cache
			   self?.savePlayersToCache(data: data)

			   // Update UI-related properties on the main thread
			   DispatchQueue.main.async {
				  self?.players = sortedPlayers
				  self?.cacheSize = cacheSize
				  self?.cacheAgeDescription = cacheAgeDescription
				  print("[fetchAllPlayers]: Successfully fetched and loaded player data.")
			   }
			}
		 } catch {
			print("[fetchAllPlayers]: Failed to decode player data: \(error.localizedDescription)")
		 }
	  }.resume()
   }

   // Helper method to save data to cache
   private func savePlayersToCache(data: Data) {
	  let cacheURL = CacheManager.shared.getCacheDirectory().appendingPathComponent(cacheFileName)
	  do {
		 try data.write(to: cacheURL)
		 print("[savePlayersToCache]: Successfully saved player data to cache.")
	  } catch {
		 print("[savePlayersToCache]: Failed to save player data to cache: \(error.localizedDescription)")
	  }
   }


   // Fetch players by name or ID using a lookup query
   func fetchPlayersByLookup(playerLookup: String) {
	  print("[fetchPlayersByLookup:] Performing player lookup with query: \(playerLookup)")
	  loadPlayersFromCache()

	  if playerLookup.allSatisfy({ $0.isNumber }) {
		 self.players = players.filter { $0.id == playerLookup }
	  } else {
		 let lookupLowercased = playerLookup.lowercased()
		 self.players = players.filter {
			let fullName = "\($0.firstName ?? "") \($0.lastName ?? "")".lowercased()
			return fullName.contains(lookupLowercased)
		 }
	  }
	  print("[fetchPlayersByLookup:] Found \(self.players.count) players matching the query.")
   }

   // Load players from the cache
   func loadPlayersFromCache() {
	  let cacheURL = CacheManager.shared.getCacheDirectory().appendingPathComponent(cacheFileName)

	  guard FileManager.default.fileExists(atPath: cacheURL.path) else {
		 print("[loadPlayersFromCache:] Cache file does not exist at \(cacheURL.path). Fetching data from network.")
		 fetchAllPlayers()
		 return
	  }

	  do {
		 // Check cache age before loading data
		 if let cacheAgeInDays = calculateCacheAgeInDays(), cacheAgeInDays < Int(maxCacheDays) {
			let cachedPlayers = try Data(contentsOf: cacheURL)
			let decodedPlayers = try JSONDecoder().decode([PlayerModel].self, from: cachedPlayers)
			DispatchQueue.main.async {
			   self.players = decodedPlayers
			   self.cacheSize = self.calculateCacheSize()
			   self.cacheAgeDescription = "Cache Age: \(cacheAgeInDays) day(s)"
			}
			print("[loadPlayersFromCache:] Loaded data from cache.")
		 } else {
			print("[loadPlayersFromCache:] Cache is older than \(maxCacheDays) days. Fetching fresh data.")
			fetchAllPlayers()
		 }
	  } catch {
		 print("[loadPlayersFromCache:] Failed to load data from cache: \(error.localizedDescription). Fetching data from network.")
		 fetchAllPlayers()
	  }
   }


   // Calculate the cache age in days
   func calculateCacheAgeInDays() -> Int? {
	  let cacheURL = CacheManager.shared.getCacheDirectory().appendingPathComponent(cacheFileName)
	  if let attributes = try? FileManager.default.attributesOfItem(atPath: cacheURL.path),
		 let modificationDate = attributes[.modificationDate] as? Date {
		 let currentDate = Date()
		 return Calendar.current.dateComponents([.day], from: modificationDate, to: currentDate).day
	  }
	  return nil
   }

   // Calculate the cache size
   func calculateCacheSize() -> String? {
	  let cacheURL = CacheManager.shared.getCacheDirectory().appendingPathComponent(cacheFileName)
	  if let attributes = try? FileManager.default.attributesOfItem(atPath: cacheURL.path),
		 let fileSize = attributes[.size] as? UInt64 {
		 let fileSizeInMB = Double(fileSize) / (1024 * 1024)
		 return String(format: "%.2f MB", fileSizeInMB)
	  }
	  return nil
   }

   // Calculate the cache age description
   func calculateCacheAge() -> String {
	  if let cacheAgeInDays = calculateCacheAgeInDays() {
		 return "Cache Age: \(cacheAgeInDays) day(s)"
	  }
	  return "Cache Age: Unknown"
   }

   // Reload players and refresh cache
   func reloadCache() {
	  print("[reloadCache:] Reloading cache...")
	  fetchAllPlayers()
   }
}
