// NFLScheduleViewModel.swift
import Foundation
import Combine
import SwiftUI

class NFLScheduleViewModel: ObservableObject {
   @Published var schedule: NFLScheduleModel?
   @Published var errorMessage: String?
   private var cancellables = Set<AnyCancellable>()

   private let scoreboardURL = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard")!

   func fetchSchedule(completion: @escaping (Bool) -> Void) {
	  URLSession.shared.dataTaskPublisher(for: scoreboardURL)
		 .map { $0.data }
		 .decode(type: NFLScheduleModel.self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { completionStatus in
			switch completionStatus {
			   case .failure(let error):
				  print("[NFLScheduleViewModel] Error fetching schedule: \(error)")
				  self.errorMessage = error.localizedDescription
				  completion(false)
			   case .finished:
				  break
			}
		 }, receiveValue: { scheduleModel in
			self.schedule = scheduleModel
			completion(true)
		 })
		 .store(in: &self.cancellables)
   }

   func getMatchupForTeam(teamAbbreviation: String) -> MatchupInfo? {
	  guard let events = schedule?.events else { return nil }

	  let teamAbbr = teamAbbreviation.uppercased()
	  let filteredEvents = events.filter { event in
		 event.competitions.contains(where: {
			$0.competitors.contains(where: { $0.team.abbreviation.uppercased() == teamAbbr })
		 })
	  }

	  guard let event = filteredEvents.first else { return nil }
	  guard let competition = event.competitions.first else { return nil }

	  let homeCompetitor = competition.competitors.first(where: { $0.homeAway == "home" })
	  let awayCompetitor = competition.competitors.first(where: { $0.homeAway == "away" })
	  guard let home = homeCompetitor, let away = awayCompetitor else { return nil }

	  let formatter = ISO8601DateFormatter()
	  guard let startDate = formatter.date(from: competition.startDate) else { return nil }

	  let state = competition.status.type.state
	  let isLive = (state == "in")

	  let homeScore = Int(home.score)
	  let awayScore = Int(away.score)

	  let dateFormatter = DateFormatter()
	  dateFormatter.dateFormat = "E h:mma" // "Sun 4:25PM"
	  let detailString = dateFormatter.string(from: startDate)

	  return MatchupInfo(
		 homeTeam: home.team.abbreviation,
		 awayTeam: away.team.abbreviation,
		 startTime: startDate,
		 isLive: isLive,
		 homeScore: homeScore,
		 awayScore: awayScore,
		 gameDetail: detailString
	  )
   }
}
