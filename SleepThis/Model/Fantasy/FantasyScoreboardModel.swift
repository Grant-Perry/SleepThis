import SwiftUI
import Combine
import Foundation

// MARK: - FantasyMatchups Namespace
enum FantasyMatchups {

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
   class FantasyScoreboardModel {
	  static let shared = FantasyScoreboardModel()
	  private var cancellable: AnyCancellable?
	  private var cache: ScoreboardResponse?

	  private init() {}

	  func getScoreboardData(forWeek week: Int, forYear year: Int, forceRefresh: Bool = false, completion: @escaping (ScoreboardResponse?) -> Void) {
		 if !forceRefresh, let cache = cache {
			completion(cache)
			return
		 }

		 guard let url = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard?seasontype=2&week=\(week)&dates=\(year)") else {
//		 guard let url = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard?week=\(week)") else {
			completion(nil)
			return
		 }

		 cancellable = URLSession.shared.dataTaskPublisher(for: url)
			.map { $0.data }
			.decode(type: ScoreboardResponse.self, decoder: JSONDecoder())
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in },
				  receiveValue: { [weak self] response in
			   self?.cache = response
			   completion(response)
			})
	  }
   }
}
