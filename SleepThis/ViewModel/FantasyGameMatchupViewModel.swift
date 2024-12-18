import SwiftUI
import Combine

// MARK: - FantasyGameMatchupViewModel
class FantasyGameMatchupViewModel: ObservableObject {
   @Published var awayTeamAbbrev: String = ""
   @Published var homeTeamAbbrev: String = ""
   @Published var awayScore: Int = 0
   @Published var homeScore: Int = 0
   @Published var quarterTime: String = ""
   @Published var dayTime: String = ""
   @Published var liveMatchup: Bool = false

   var teamAbbreviation: String = ""
   var refreshTimer: AnyCancellable?
   var refreshInterval: Int = 0

   func configure(teamAbbreviation: String, week: Int, year: Int, refreshInterval: Int = 0) {
	  self.teamAbbreviation = teamAbbreviation
	  self.refreshInterval = refreshInterval
	  fetchData(forWeek: week, forYear: year)

	  refreshTimer?.cancel()
	  guard refreshInterval > 0 else { return }
	  refreshTimer = Timer.publish(every: TimeInterval(refreshInterval), on: .main, in: .common)
		 .autoconnect()
		 .sink { [weak self] _ in
			self?.fetchData(forWeek: week, forYear: year, forceRefresh: true)
		 }
   }

   func fetchData(forWeek week: Int, forYear year: Int, forceRefresh: Bool = false) {
	  FantasyMatchups.FantasyScoreboardModel.shared.getScoreboardData(forWeek: week, forYear: year, forceRefresh: forceRefresh) { [weak self] response in
		 guard let self = self, let response = response else { return }
		 self.processScoreboard(response: response)
	  }
   }

   func processScoreboard(response: FantasyMatchups.ScoreboardResponse) {
	  awayTeamAbbrev = ""
	  homeTeamAbbrev = ""
	  awayScore = 0
	  homeScore = 0
	  quarterTime = ""
	  dayTime = ""
	  liveMatchup = false

	  guard let competition = response.events
		 .flatMap({ $0.competitions })
		 .first(where: { comp in
			comp.competitors.contains { $0.team.abbreviation.uppercased() == teamAbbreviation.uppercased() }
		 }) else {
		 return
	  }

	  setCompetitionData(competition)
   }

   private func setCompetitionData(_ competition: FantasyMatchups.SBCompetition) {
	  let comps = competition.competitors
	  guard comps.count == 2 else { return }

	  guard let awayComp = comps.first(where: { $0.homeAway == "away" }),
			let homeComp = comps.first(where: { $0.homeAway == "home" }) else {
		 return
	  }

	  awayTeamAbbrev = awayComp.team.abbreviation
	  homeTeamAbbrev = homeComp.team.abbreviation
	  awayScore = Int(awayComp.score) ?? 0
	  homeScore = Int(homeComp.score) ?? 0

	  let state = competition.status.type.state
	  let detail = competition.status.type.detail
	  let completed = competition.status.type.completed

	  // Try parsing the date with ISO8601 first
	  let isoFormatter = ISO8601DateFormatter()
	  isoFormatter.formatOptions = [.withInternetDateTime]

	  var gameDate: Date? = isoFormatter.date(from: competition.date)

	  // If ISO8601 fails, try a fallback format (adjust pattern if needed)
	  if gameDate == nil {
		 let fallbackFormatter = DateFormatter()
		 fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ" // Adjust based on the actual date format
		 gameDate = fallbackFormatter.date(from: competition.date)
	  }

	  if let date = gameDate {
		 let formatter = DateFormatter()
		 formatter.dateFormat = "E MM/dd @ h a"
		 dayTime = formatter.string(from: date)
	  } else {
		 // If still no date, set to "TBD"
		 dayTime = "TBD"
	  }

	  switch state {
		 case "pre":
			quarterTime = ""
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

}
