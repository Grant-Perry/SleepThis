import SwiftUI
import Combine
import Foundation

// View model that uses FantasyMatchups.FantasyScoreboardModel to fetch and provide NFL matchup info
// for a given team. It supports auto-refreshing via a timer.
class FantasyGameMatchupViewModel: ObservableObject {
   @Published var awayTeamAbbrev: String = ""
   @Published var homeTeamAbbrev: String = ""
   @Published var awayScore: Int = 0
   @Published var homeScore: Int = 0
   @Published var quarterTime: String = ""
   @Published var dayTime: String = ""
   @Published var liveMatchup: Bool = false

   private var cancellable: AnyCancellable?
   private var teamAbbreviation: String = ""
   private var refreshTimer: AnyCancellable?
   private var refreshInterval: Int = 0

   // Configure the view model with a team abbreviation and optional refresh interval.
   // If refreshInterval > 0, it sets up a timer to auto-refresh.
   func configure(teamAbbreviation: String, refreshInterval: Int = 0) {
	  self.teamAbbreviation = teamAbbreviation
	  self.refreshInterval = refreshInterval
	  fetchData()

	  refreshTimer?.cancel()
	  guard refreshInterval > 0 else { return }
	  refreshTimer = Timer.publish(every: TimeInterval(refreshInterval), on: .main, in: .common)
		 .autoconnect()
		 .sink { [weak self] _ in
			self?.fetchData(forceRefresh: true)
		 }
   }

   // Fetch data from the scoreboard model
   func fetchData(forceRefresh: Bool = false) {
	  FantasyMatchups.FantasyScoreboardModel.shared.getScoreboardData(forceRefresh: forceRefresh) { [weak self] response in
		 guard let self = self, let response = response else { return }
		 self.processScoreboard(response: response)
	  }
   }

   // Process the scoreboard response to find the event with our teamAbbreviation
   private func processScoreboard(response: FantasyMatchups.ScoreboardResponse) {
	  // Reset all data each time we process new data
	  awayTeamAbbrev = ""
	  homeTeamAbbrev = ""
	  awayScore = 0
	  homeScore = 0
	  quarterTime = ""
	  dayTime = ""
	  liveMatchup = false

	  // Iterate through events and competitions to find our team
	  for event in response.events {
		 for competition in event.competitions {
			let comps = competition.competitors
			if comps.contains(where: { $0.team.abbreviation.uppercased() == teamAbbreviation.uppercased() }) {
			   // Found the event for this team
			   if comps.count == 2 {
				  let awayComp = comps.first(where: { $0.homeAway == "away" })
				  let homeComp = comps.first(where: { $0.homeAway == "home" })
				  awayTeamAbbrev = awayComp?.team.abbreviation ?? ""
				  homeTeamAbbrev = homeComp?.team.abbreviation ?? ""
				  awayScore = Int(awayComp?.score ?? "0") ?? 0
				  homeScore = Int(homeComp?.score ?? "0") ?? 0

				  let state = competition.status.type.state
				  let detail = competition.status.type.detail
				  let completed = competition.status.type.completed

				  // Determine game state
				  switch state {
					 case "pre":
						// Game not started
						if let date = ISO8601DateFormatter().date(from: competition.date) {
						   let formatter = DateFormatter()
						   formatter.dateFormat = "E MM/dd @ h a"
						   dayTime = formatter.string(from: date)
						} else {
						   dayTime = "TBD"
						}
						quarterTime = "Not Started"
						liveMatchup = false
					 case "in":
						// Game in progress
						quarterTime = detail
						liveMatchup = true
						if let date = ISO8601DateFormatter().date(from: competition.date) {
						   let formatter = DateFormatter()
						   formatter.dateFormat = "E MM/dd @ h a"
						   dayTime = formatter.string(from: date)
						} else {
						   dayTime = "Live"
						}
					 case "post":
						// Game finished
						quarterTime = "Final"
						liveMatchup = false
						if let date = ISO8601DateFormatter().date(from: competition.date) {
						   let formatter = DateFormatter()
						   formatter.dateFormat = "E MM/dd @ h a"
						   dayTime = formatter.string(from: date)
						} else {
						   dayTime = "Ended"
						}
					 default:
						// Delayed or other state
						quarterTime = detail
						liveMatchup = !completed
						if let date = ISO8601DateFormatter().date(from: competition.date) {
						   let formatter = DateFormatter()
						   formatter.dateFormat = "E MM/dd @ h a"
						   dayTime = formatter.string(from: date)
						} else {
						   dayTime = "TBD"
						}
				  }
			   }
			   return
			}
		 }
	  }
   }
}
