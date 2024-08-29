import Foundation
import Combine

class ESPNViewModel: ObservableObject {
   @Published var playerDetails: ESPNPlayerModel?

   private var cancellables = Set<AnyCancellable>()

   func fetchPlayerDetails(by name: String) {
	  let query = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
	  let urlString = "https://site.api.espn.com/apis/site/v2/sports/football/nfl/athletes/\(query)"

	  guard let url = URL(string: urlString) else {
		 print("[fetchPlayerDetails:] Invalid URL")
		 return
	  }

	  URLSession.shared.dataTaskPublisher(for: url)
		 .map(\.data)
		 .decode(type: ESPNPlayerModel.self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { completion in
			switch completion {
			   case .failure(let error):
				  print("[fetchPlayerDetails:] Error: \(error.localizedDescription)")
			   case .finished:
				  break
			}
		 }, receiveValue: { [weak self] playerDetails in
			self?.playerDetails = playerDetails
			print("[fetchPlayerDetails:] Successfully fetched player details for \(playerDetails.fullName)")
		 })
		 .store(in: &cancellables)
   }
}
