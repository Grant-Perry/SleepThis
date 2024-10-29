import Foundation
import Combine

class FantasyViewModel: ObservableObject {
   @Published var matchups: [Fantasy.Matchup] = []
   @Published var isLoading = false
   @Published var errorMessage: String?

   private var cancellables = Set<AnyCancellable>()

   // No cache - only network fetch
   func fetchFantasyData(forWeek week: Int = 7) {
	  guard let url = URL(string:
						  "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/2024/segments/0/leagues/\(AppConstants.ESPNLeagueID)?view=mMatchup&view=mMatchupScore&view=mRoster&view=mScoreboard&view=mSettings&view=mStatus&view=mTeam&view=modular&view=mNav") else {
		 self.errorMessage = "Invalid URL"
		 return
	  }

	  var request = URLRequest(url: url)
	  request.httpMethod = "GET"
	  let cookieString = "SWID=\(AppConstants.SWID); espn_s2=\(AppConstants.ESPN_S2)"
	  request.setValue(cookieString, forHTTPHeaderField: "Cookie")
	  request.setValue("application/json", forHTTPHeaderField: "Accept")

	  self.isLoading = true

	  URLSession.shared.dataTaskPublisher(for: request)
		 .map { $0.data }
		 .receive(on: DispatchQueue.main) // Ensure changes are received on the main thread
		 .decode(type: Fantasy.Model.self, decoder: JSONDecoder())
		 .sink { [weak self] completion in
			DispatchQueue.main.async {
			   self?.isLoading = false
			   switch completion {
				  case .finished:
					 break
				  case .failure(let error):
					 self?.errorMessage = "Failed to load: \(error.localizedDescription)"
			   }
			}
		 } receiveValue: { [weak self] fantasyModel in
			DispatchQueue.main.async {
			   self?.matchups = fantasyModel.schedule
			}
		 }
		 .store(in: &cancellables)
   }
}
