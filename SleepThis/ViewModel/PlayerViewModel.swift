import SwiftUI
import Foundation
import Combine

class PlayerViewModel: ObservableObject {
   @Published var players: [PlayerModel] = []
   @Published var isLoading = false
   @Published var errorMessage: String?
   @Published var cacheSize: String?
   @Published var cacheAgeDescription: String?

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
			   // Decode player dictionary
			   let playersDictionary = try JSONDecoder().decode([String: PlayerModel].self, from: data)

			   // Convert the dictionary values to an array of PlayerModel and filter the relevant positions
			   self.players = playersDictionary.values.filter { player in
				  guard let position = player.position,
						let team = player.team,
						let depthChartPosition = player.depthChartPosition else { return false }
				  // Filter out players with "Unknown" values and keep only relevant positions
				  return ["QB", "RB", "WR", "TE", "K", "DST"].contains(position) &&
				  team.lowercased() != "unknown" &&
				  position.lowercased() != "unknown" &&
				  depthChartPosition.lowercased() != "unknown"
			   }

			   // Save to cache after fetching from network
			   CacheManager.shared.saveToCache(self.players, as: self.cacheFileName)
			   self.cacheSize = self.calculateCacheSize()
			   self.cacheAgeDescription = self.calculateCacheAge()
			   print("[fetchAllPlayers:] Successfully saved data to cache.")
			} catch {
			   print("[fetchAllPlayers:] Failed to decode player data: \(error)")
			   self.errorMessage = "Failed to decode player data: \(error)"
			}
		 }
	  }.resume()
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
			self.players = decodedPlayers
			self.cacheSize = calculateCacheSize()
			self.cacheAgeDescription = "Cache Age: \(cacheAgeInDays) day(s)"
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
