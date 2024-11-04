//// This is the previous ESPN version - IT WORKS
//import SwiftUI
//import Combine
//
//class FantasyMatchupViewModelPrev: ObservableObject {
//   @Published var espnFantasyModel: ESPNFantasy.ESPNFantasyModel?
//   @Published var matchups: [ESPNFantasy.ESPNFantasyModel.Matchup] = []
//   @Published var isLoading: Bool = false
//   @Published var errorMessage: String? = nil
//   @Published var selectedYear = Calendar.current.component(.year, from: Date())
//   @Published var selectedWeek: Int = {
//	  let firstWeek = 36
//	  let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
//	  let offset = currentWeek >= firstWeek ? currentWeek - firstWeek + 1 : 0
//	  return min(max(1, offset), 17)
//   }()
//
//   private var leagueID = AppConstants.ESPNLeagueID
//   private var cancellables = Set<AnyCancellable>()
//
//   func fetchFantasyData(forWeek week: Int) {
//	  guard let url = URL(string: "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/\(selectedYear)/segments/0/leagues/\(leagueID)?view=mMatchupScore&view=mLiveScoring&view=mRoster&scoringPeriodId=\(week)") else {
//		 return
//	  }
//
//	  isLoading = true
//	  errorMessage = nil
//
//	  var request = URLRequest(url: url)
//	  request.addValue("application/json", forHTTPHeaderField: "Accept")
//	  request.addValue("SWID=\(AppConstants.SWID); espn_s2=\(AppConstants.ESPN_S2)", forHTTPHeaderField: "Cookie")
//
//	  URLSession.shared.dataTaskPublisher(for: request)
//		 .map { $0.data }
//		 .decode(type: ESPNFantasy.ESPNFantasyModel.self, decoder: JSONDecoder())
//		 .receive(on: DispatchQueue.main)
//		 .sink(receiveCompletion: { [weak self] completion in
//			self?.isLoading = false
//			if case .failure(let error) = completion {
//			   self?.errorMessage = "Error fetching data: \(error)"
//			}
//		 }, receiveValue: { [weak self] model in
//			self?.espnFantasyModel = model
//			self?.matchups = model.schedule.filter { $0.matchupPeriodId == week }
//		 })
//		 .store(in: &cancellables)
//   }
//
//   func getTeam(for teamId: Int) -> ESPNFantasy.ESPNFantasyModel.Team? {
//	  return espnFantasyModel?.teams.first(where: { $0.id == teamId })
//   }
//}
