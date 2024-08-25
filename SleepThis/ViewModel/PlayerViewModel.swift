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

	  // Example API URL to fetch a player by ID or name
	  let urlString = "https://example.com/api/players/\(playerLookup)"
	  guard let url = URL(string: urlString) else {
		 self.errorMessage = "Invalid URL"
		 return
	  }

	  URLSession.shared.dataTask(with: url) { data, response, error in
		 DispatchQueue.main.async {
			self.isLoading = false

			if let error = error {
			   self.errorMessage = error.localizedDescription
			   return
			}

			guard let data = data else {
			   self.errorMessage = "No data received"
			   return
			}

			do {
			   let player = try JSONDecoder().decode(PlayerModel.self, from: data)
			   self.players = [player]  // Assuming fetch by a single player
			} catch {
			   self.errorMessage = "Failed to decode player data"
			}
		 }
	  }.resume()
   }

   func reloadCache() {
	  loadCachedPlayers()
   }

    func loadCachedPlayers() {
	  if let cachedData = UserDefaults.standard.data(forKey: playersCacheKey) {
		 do {
			let players = try JSONDecoder().decode([PlayerModel].self, from: cachedData)
			self.players = players
		 } catch {
			self.errorMessage = "Failed to decode cached players"
		 }
	  } else {
		 fetchAndCachePlayersFromSleeper()
	  }
   }

   private func fetchAndCachePlayersFromSleeper() {
	  isLoading = true
	  errorMessage = nil

	  // Replace with actual Sleeper API URL
	  let urlString = "https://api.sleeper.app/v1/players/nfl"
	  guard let url = URL(string: urlString) else {
		 self.errorMessage = "Invalid URL"
		 return
	  }

	  URLSession.shared.dataTask(with: url) { data, response, error in
		 DispatchQueue.main.async {
			self.isLoading = false

			if let error = error {
			   self.errorMessage = error.localizedDescription
			   return
			}

			guard let data = data else {
			   self.errorMessage = "No data received"
			   return
			}

			do {
			   let players = try JSONDecoder().decode([String: PlayerModel].self, from: data)
			   self.players = Array(players.values)
			   self.savePlayersToCache(data)
			} catch {
			   self.errorMessage = "Failed to decode player data"
			}
		 }
	  }.resume()
   }

   private func savePlayersToCache(_ data: Data) {
	  let defaults = UserDefaults.standard
	  defaults.set(data, forKey: playersCacheKey)
	  defaults.set(Date(), forKey: cacheDateKey)
   }

   func fetchMatchups(leagueID: String, week: Int) {
	  isLoading = true

	  let urlString = "https://example.com/api/league/\(leagueID)/week/\(week)/matchups" // Replace with actual API endpoint
	  guard let url = URL(string: urlString) else {
		 self.errorMessage = "Invalid URL"
		 return
	  }

	  URLSession.shared.dataTask(with: url) { data, response, error in
		 DispatchQueue.main.async {
			self.isLoading = false

			if let error = error {
			   self.errorMessage = error.localizedDescription
			   return
			}

			guard let data = data else {
			   self.errorMessage = "No data received"
			   return
			}

			do {
			   let matchups = try JSONDecoder().decode([MatchupModel].self, from: data)
			   self.matchups = matchups
			   self.saveMatchupsToCache(matchups: matchups)
			} catch {
			   self.errorMessage = "Failed to decode matchup data"
			}
		 }
	  }.resume()
   }

   private func saveMatchupsToCache(matchups: [MatchupModel]) {
	  // Cache saving logic for matchups
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
