import Foundation
import Combine
import SwiftUI

class PlayerViewModel: ObservableObject {
   // Properties
   @Published var players: [PlayerModel] = []
   @Published var matchups: [MatchupModel] = []
   @Published var isLoading = false
   @Published var errorMessage: String?
   @Published var cacheSize: String?

   var cacheAgeDescription: String? {
	  return getLocalizedCacheAgeDescription()
   }

   private var cancellable: AnyCancellable?
   private let cacheFileName = "players_cache.json"
   private let cacheExpiryKey = "cache_expiry"
   private let cacheDuration: TimeInterval = 60 * 60 * 24 * 5  // 5 days

   // Method to get the cache age description
   func getLocalizedCacheAgeDescription() -> String {
	  let cacheAge = getCacheAge()
	  let dayLabel = cacheAge > 1 ? "days" : "day"
	  return "Cache Age: \(cacheAge) \(dayLabel)"
   }

   // Method to calculate cache age in days
   func getCacheAge() -> Int {
	  let defaults = UserDefaults.standard
	  if let expiryDate = defaults.object(forKey: cacheExpiryKey) as? Date {
		 let elapsedDays = max(1, Int(Date().timeIntervalSince(expiryDate) / (60 * 60 * 24)))
		 return elapsedDays
	  }
	  return 1 // Default to 1 day if cache does not exist
   }

   // Method to fetch matchups from the API
   func fetchMatchups(week: Int) {
	  let leagueID = "1051207774316683264"
	  let urlString = "https://api.sleeper.app/v1/league/\(leagueID)/matchups/\(week)"
	  guard let url = URL(string: urlString) else {
		 self.errorMessage = "Invalid URL"
		 return
	  }

	  isLoading = true

	  cancellable = URLSession.shared.dataTaskPublisher(for: url)
		 .map { $0.data }
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { completionStatus in
			self.isLoading = false
			if case .failure(let error) = completionStatus {
			   self.errorMessage = error.localizedDescription
			}
		 }, receiveValue: { data in
			do {
			   self.matchups = try JSONDecoder().decode([MatchupModel].self, from: data)
			} catch {
			   self.errorMessage = "Failed to parse matchups data"
			}
		 })
   }

   // Method to map player IDs to player names
   func getPlayerNames(from ids: [String]) -> String {
	  return ids.compactMap { id in
		 self.players.first(where: { $0.id == id })?.fullName
	  }.joined(separator: ", ")
   }

   // Method to reload the cache
   func reloadCache() {
	  fetchAndCacheData { [weak self] data in
		 guard let self = self else { return }
		 do {
			let players = try JSONDecoder().decode([String: PlayerModel].self, from: data)
			self.players = Array(players.values)
			self.errorMessage = nil
		 } catch {
			self.errorMessage = "Failed to parse player data"
		 }
	  }
   }

   // Method to fetch player data
   func fetchPlayer(playerLookup: String) {
	  if let cachedData = loadCachedData(), let players = try? JSONDecoder().decode([String: PlayerModel].self, from: cachedData) {
		 self.players = Array(players.values)
		 if self.players.isEmpty {
			self.errorMessage = "Player not found"
		 }
		 return
	  }

	  fetchAndCacheData { [weak self] data in
		 guard let self = self else { return }
		 do {
			let players = try JSONDecoder().decode([String: PlayerModel].self, from: data)
			self.players = Array(players.values)
			self.errorMessage = nil
		 } catch {
			self.errorMessage = "Failed to parse player data"
		 }
	  }
   }

   // Method to fetch and cache data
   private func fetchAndCacheData(completion: @escaping (Data) -> Void) {
	  guard let url = URL(string: "https://api.sleeper.app/v1/players/nfl") else {
		 self.errorMessage = "Invalid URL"
		 return
	  }

	  isLoading = true
	  errorMessage = nil

	  cancellable = URLSession.shared.dataTaskPublisher(for: url)
		 .map { $0.data }
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { completionStatus in
			self.isLoading = false
			if case .failure(let error) = completionStatus {
			   self.errorMessage = error.localizedDescription
			}
		 }, receiveValue: { data in
			self.saveCacheData(data)
			completion(data)
		 })
   }

   // Method to load cached data
   private func loadCachedData() -> Data? {
	  let fileURL = getDocumentsDirectory().appendingPathComponent(cacheFileName)
	  let defaults = UserDefaults.standard
	  if let expiryDate = defaults.object(forKey: cacheExpiryKey) as? Date, Date() < expiryDate {
		 return try? Data(contentsOf: fileURL)
	  }
	  return nil
   }

   // Method to save cache data
   private func saveCacheData(_ data: Data) {
	  let fileURL = getDocumentsDirectory().appendingPathComponent(cacheFileName)
	  try? data.write(to: fileURL)

	  let cacheExpiryDate = Date().addingTimeInterval(cacheDuration)
	  UserDefaults.standard.set(cacheExpiryDate, forKey: cacheExpiryKey)
   }

   // Method to get the documents directory
   private func getDocumentsDirectory() -> URL {
	  return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
   }

   // Convert height to feet and inches
   func convertHeightToFeetAndInches(height: String?) -> String {
	  guard let heightInInches = Int(height ?? "") else {
		 return "Unknown"
	  }

	  let feet = heightInInches / 12
	  let inches = heightInInches % 12
	  return "\(feet)'\(inches)\""
   }

   
}
