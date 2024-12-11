// #fuc
import SwiftUI
import Combine
import Foundation

// MARK: - FantasyMatchups Namespace
// This namespace (enum) will contain scoreboard-related models and view models to avoid conflicts.
enum FantasyMatchups {

   // MARK: - Scoreboard Data Models
   // Prefixed structs with SB to avoid conflicts with other Team/Competitor structs.
   struct ScoreboardResponse: Codable {
	  let events: [SBEvent]
   }

   struct SBEvent: Codable {
	  let id: String
	  let name: String
	  let date: String
	  let competitions: [SBCompetition]
   }

   struct SBCompetition: Codable {
	  let competitors: [SBCompetitor]
	  let status: SBStatus
	  let date: String
   }

   struct SBCompetitor: Codable {
	  let id: String
	  let homeAway: String
	  let score: String
	  let team: SBTeam
   }

   struct SBTeam: Codable {
	  let abbreviation: String
   }

   struct SBStatus: Codable {
	  let type: SBStatusType
   }

   struct SBStatusType: Codable {
	  let state: String
	  let detail: String
	  let shortDetail: String
	  let completed: Bool
	  let description: String
   }

   // MARK: - FantasyScoreboardModel
   // This class fetches and caches the NFL scoreboard data.
   // No TTL is required because we're refreshing whenever interval triggers a fetch.
   class FantasyScoreboardModel {
	  static let shared = FantasyScoreboardModel()
	  private var cancellable: AnyCancellable?
	  private var cache: ScoreboardResponse?

	  private init() {}

	  // Fetch NFL scoreboard data.
	  // If forceRefresh = false and we have a cache, use it.
	  // If forceRefresh = true, we refetch from the API.
	  func getScoreboardData(forceRefresh: Bool = false, completion: @escaping (ScoreboardResponse?) -> Void) {
		 if !forceRefresh, let cache = cache {
			// Return cached data
			completion(cache)
			return
		 }

		 guard let url = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard") else {
			completion(nil)
			return
		 }

		 cancellable = URLSession.shared.dataTaskPublisher(for: url)
			.map { $0.data }
			.decode(type: ScoreboardResponse.self, decoder: JSONDecoder())
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in
			   // We ignore errors silently here, could add logging if needed.
			}, receiveValue: { [weak self] response in
			   self?.cache = response
			   completion(response)
			})
	  }
   }
}
