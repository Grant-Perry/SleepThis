import Foundation
import Combine
import Observation

@Observable

class LeagueDetailViewModel: ObservableObject {
   var league: LeagueModel?
   private var cancellables = Set<AnyCancellable>()
   private var maxCacheDays = AppConstants.maxCacheDays

   func fetchLeague(leagueID: String) {
	  // Check if cached data exists and is valid
	  if let cachedLeague = loadLeagueFromCache(leagueID: leagueID), !isCacheExpired(leagueID: leagueID) {
		 print("[LeagueDetailViewModel] Loaded league from cache.")
		 self.league = cachedLeague
		 return
	  }

	  // If no valid cache, fetch from API
	  guard let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)") else {
		 print("[LeagueDetailViewModel] Invalid URL.")
		 return
	  }

	  URLSession.shared.dataTaskPublisher(for: url)
		 .map { $0.data }
		 .decode(type: LeagueModel.self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { completion in
			if case let .failure(error) = completion {
			   print("[LeagueDetailViewModel] Error fetching league: \(error)")
			}
		 }, receiveValue: { [weak self] league in
			self?.league = league
			self?.saveLeagueToCache(leagueID: leagueID, league: league)
			print("[LeagueDetailViewModel] Fetched league from API and saved to cache.")
		 })
		 .store(in: &cancellables)
   }

   // MARK: - Caching Methods

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
		 print("[LeagueDetailViewModel] Unable to get cache file URL.")
		 return
	  }

	  do {
		 let data = try JSONEncoder().encode(league)
		 try data.write(to: fileURL)
		 print("[LeagueDetailViewModel] League data saved to cache.")
	  } catch {
		 print("[LeagueDetailViewModel] Error saving league to cache: \(error)")
	  }
   }

   private func loadLeagueFromCache(leagueID: String) -> LeagueModel? {
	  guard let fileURL = getCacheFileURL(leagueID: leagueID) else {
		 print("[LeagueDetailViewModel] Unable to get cache file URL.")
		 return nil
	  }

	  do {
		 let data = try Data(contentsOf: fileURL)
		 let league = try JSONDecoder().decode(LeagueModel.self, from: data)
		 return league
	  } catch {
		 print("[LeagueDetailViewModel] Error loading league from cache: \(error)")
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
			return daysDifference >= Int(maxCacheDays)
		 } else {
			return true
		 }
	  } catch {
		 print("[LeagueDetailViewModel] Error checking cache file attributes: \(error)")
		 return true
	  }
   }
}
