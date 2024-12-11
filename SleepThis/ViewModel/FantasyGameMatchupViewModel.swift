
import SwiftUI
import Combine
import Foundation

// This ViewModel fetches and provides NFL matchup info for a given team abbreviation.
// Uses FantasyMatchups.FantasyScoreboardModel to fetch scoreboard data.
// Supports auto-refresh using a timer if refreshInterval > 0.
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

   // Configure the view model with a team abbreviation (like "BUF") and optional refresh interval.
   // If refreshInterval > 0, sets up a timer to auto-refresh data.
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

   // Fetch data from scoreboard model.
   // forceRefresh = true to ignore cached data.
   func fetchData(forceRefresh: Bool = false) {
	  FantasyMatchups.FantasyScoreboardModel.shared.getScoreboardData(forceRefresh: forceRefresh) { [weak self] response in
		 guard let self = self, let response = response else { return }
		 self.processScoreboard(response: response)
	  }
   }

   // Process the scoreboard to find the event and competition for the configured team.
   // Update published vars accordingly.
   private func processScoreboard(response: FantasyMatchups.ScoreboardResponse) {
	  // Reset values
	  awayTeamAbbrev = ""
	  homeTeamAbbrev = ""
	  awayScore = 0
	  homeScore = 0
	  quarterTime = ""
	  dayTime = ""
	  liveMatchup = false

	  for event in response.events {
		 for competition in event.competitions {
			let comps = competition.competitors
			if comps.contains(where: { $0.team.abbreviation.uppercased() == teamAbbreviation.uppercased() }) {
			   // Found the relevant competition
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
				  if let date = ISO8601DateFormatter().date(from: competition.date) {
					 let formatter = DateFormatter()
					 formatter.dateFormat = "E MM/dd @ h a"
					 dayTime = formatter.string(from: date)
				  } else {
					 dayTime = "TBD"
				  }

				  switch state {
					 case "pre":
						quarterTime = "" // was "Not Started"
						liveMatchup = false
					 case "in":
						quarterTime = detail
						liveMatchup = true
					 case "post":
						quarterTime = "Final"
						liveMatchup = false
					 default:
						quarterTime = detail
						liveMatchup = !completed
				  }
			   }
			   return
			}
		 }
	  }
   }
}
