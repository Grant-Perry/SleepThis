import SwiftUI
import Combine
import Foundation

// MARK: - FantasyMatchups Namespace
// This namespace (enum) will contain all scoreboard related models and view models.
enum FantasyMatchups {

   // MARK: - Scoreboard Data Models
   // These structs are specifically for the ESPN NFL scoreboard API response.

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
   // This class fetches and caches the scoreboard data. Since we are updating the cache
   // for every refresh interval update, we do not need a TTL here.
   class FantasyScoreboardModel {
	  static let shared = FantasyScoreboardModel()
	  private var cancellable: AnyCancellable?
	  private var cache: ScoreboardResponse?

	  private init() {}

	  // Fetch the NFL scoreboard data
	  // forceRefresh = true will ignore the cache and fetch new data
	  func getScoreboardData(forceRefresh: Bool = false, completion: @escaping (ScoreboardResponse?) -> Void) {
		 if !forceRefresh, let cache = cache {
			// Return cached data if not forcing refresh
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
			.sink(receiveCompletion: { completionStatus in
			   // If there's an error, return nil
			   if case .failure(_) = completionStatus {
				  completion(nil)
			   }
			}, receiveValue: { [weak self] response in
			   // Cache the response
			   self?.cache = response
			   // Return the response via completion handler
			   completion(response)
			})
	  }
   }
}
