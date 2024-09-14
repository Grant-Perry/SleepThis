import Foundation
import Combine

class LeagueViewModel: ObservableObject {
   @Published var leagues: [LeagueModel] = []
   private var cancellables = Set<AnyCancellable>()

   func fetchLeaguesForUser(userID: String) {
	  // Construct the API URL to fetch all leagues for the user
//	  print("url: https://api.sleeper.app/v1/user/\(userID)/leagues/nfl/2024\n----====----====--\n")
	  guard let url = URL(string: "https://api.sleeper.app/v1/user/\(userID)/leagues/nfl/2024") else {
		 print("[LeagueViewModel] Invalid URL.")
		 return
	  }

	  URLSession.shared.dataTaskPublisher(for: url)
		 .map { $0.data }
		 .decode(type: [LeagueModel].self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { completion in
			if case let .failure(error) = completion {
			   print("[LeagueViewModel] Error fetching leagues: \(error)")
			}
		 }, receiveValue: { [weak self] leagues in
			self?.leagues = leagues
			self?.saveLeaguesToCache(userID: userID, leagues: leagues)
			print("[LeagueViewModel] Fetched leagues from API and saved to cache.")
		 })
		 .store(in: &cancellables)
   }

   // MARK: - Caching Methods


   func fetchLeague(leagueID: String, completion: @escaping (LeagueModel?) -> Void) {
	  // Check if cached data exists and is valid
	  if let cachedLeague = loadLeagueFromCache(leagueID: leagueID), !isCacheExpired(leagueID: leagueID) {
		 print("[LeagueViewModel] Loaded league from cache.")
		 completion(cachedLeague)
		 return
	  }

	  // If no valid cache, fetch from API
	  guard let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)") else {
		 print("[LeagueViewModel] Invalid URL.")
		 completion(nil)
		 return
	  }

	  URLSession.shared.dataTaskPublisher(for: url)
		 .map { $0.data }
		 .decode(type: LeagueModel.self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { completionStatus in
			if case let .failure(error) = completionStatus {
			   print("[LeagueViewModel] Error fetching league: \(error)")
			   completion(nil)
			}
		 }, receiveValue: { [weak self] league in
			self?.saveLeagueToCache(leagueID: leagueID, league: league)
			print("[LeagueViewModel] Fetched league from API and saved to cache.")
			completion(league)
		 })
		 .store(in: &cancellables)
   }

   // Add caching methods for single league
   private func getCacheFileURL(leagueID: String) -> URL? {
	  let filename = "\(leagueID)_league.json"
	  let fileManager = FileManager.default
	  if let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
		 return cacheDir.appendingPathComponent(filename)
	  }
	  return nil
   }

   private func saveLeagueToCache(leagueID: String, league: LeagueModel) {
	  guard let fileURL = getCacheFileURL(leagueID: leagueID) else {
		 print("[LeagueViewModel] Unable to get cache file URL.")
		 return
	  }

	  do {
		 let data = try JSONEncoder().encode(league)
		 try data.write(to: fileURL)
		 print("[LeagueViewModel] League data saved to cache.")
	  } catch {
		 print("[LeagueViewModel] Error saving league to cache: \(error)")
	  }
   }

   private func loadLeagueFromCache(leagueID: String) -> LeagueModel? {
	  guard let fileURL = getCacheFileURL(leagueID: leagueID) else {
		 print("[LeagueViewModel] Unable to get cache file URL.")
		 return nil
	  }

	  do {
		 let data = try Data(contentsOf: fileURL)
		 let league = try JSONDecoder().decode(LeagueModel.self, from: data)
		 return league
	  } catch {
		 print("[LeagueViewModel] Error loading league from cache: \(error)")
		 return nil
	  }
   }

   private func isCacheExpired(leagueID: String) -> Bool {
	  guard let fileURL = getCacheFileURL(leagueID: leagueID) else {
		 return true // Treat as expired if we can't find the cache file
	  }

	  do {
		 let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
		 if let modificationDate = attributes[.modificationDate] as? Date {
			let currentDate = Date()
			let daysDifference = Calendar.current.dateComponents([.day], from: modificationDate, to: currentDate).day ?? 0
			return daysDifference >= 14
		 } else {
			return true
		 }
	  } catch {
		 print("[LeagueViewModel] Error checking cache file attributes: \(error)")
		 return true
	  }
   }




   private func getCacheFileURL(userID: String) -> URL? {
	  let filename = "\(userID)_leagues.json"
	  let fileManager = FileManager.default
	  if let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
		 return cacheDir.appendingPathComponent(filename)
	  }
	  return nil
   }

   private func saveLeaguesToCache(userID: String, leagues: [LeagueModel]) {
	  guard let fileURL = getCacheFileURL(userID: userID) else {
		 print("[LeagueViewModel] Unable to get cache file URL.")
		 return
	  }

	  do {
		 let data = try JSONEncoder().encode(leagues)
		 try data.write(to: fileURL)
		 print("[LeagueViewModel] Leagues data saved to cache.")
	  } catch {
		 print("[LeagueViewModel] Error saving leagues to cache: \(error)")
	  }
   }

   private func loadLeaguesFromCache(userID: String) -> [LeagueModel]? {
	  guard let fileURL = getCacheFileURL(userID: userID) else {
		 print("[LeagueViewModel] Unable to get cache file URL.")
		 return nil
	  }

	  do {
		 let data = try Data(contentsOf: fileURL)
		 let leagues = try JSONDecoder().decode([LeagueModel].self, from: data)
		 return leagues
	  } catch {
		 print("[LeagueViewModel] Error loading leagues from cache: \(error)")
		 return nil
	  }
   }

   private func isCacheExpired(userID: String) -> Bool {
	  guard let fileURL = getCacheFileURL(userID: userID) else {
		 return true // Treat as expired if we can't find the cache file
	  }

	  do {
		 let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
		 if let modificationDate = attributes[.modificationDate] as? Date {
			let currentDate = Date()
			let daysDifference = Calendar.current.dateComponents([.day], from: modificationDate, to: currentDate).day ?? 0
			return daysDifference >= 14
		 } else {
			return true
		 }
	  } catch {
		 print("[LeagueViewModel] Error checking cache file attributes: \(error)")
		 return true
	  }
   }

   // New performSearch method that triggers fetchLeagues
   func getLeagueByID(leagueID: String) {
	  fetchLeagues(userID: leagueID) // Trigger the fetch based on the input League ID
   }

   // Modified fetch method to check cache
   func fetchLeagues(userID: String) {
	  // Check if cached data exists and is valid
//	  if let cachedLeagues = loadLeaguesFromCache(userID: userID), !isCacheExpired(userID: userID) {
//		 print("[LeagueViewModel] Loaded leagues from cache.")
//		 self.leagues = cachedLeagues
//		 return
//	  }

	  // If no valid cache, fetch from API
	  fetchLeaguesForUser(userID: userID)
   }
}
