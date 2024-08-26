import Foundation
import Combine

class TransactionViewModel: ObservableObject {
   @Published var transactions: [TransactionModel] = []
   @Published var isLoading = false
   @Published var errorMessage: String?

   private var userViewModels: [String: UserViewModel] = [:]

   func fetchTransactions(leagueID: String, round: Int) {
	  isLoading = true

	  let urlString = "https://api.sleeper.app/v1/league/\(leagueID)/transactions/\(round)"
	  guard let url = URL(string: urlString) else {
		 self.errorMessage = "Invalid URL"
		 return
	  }

	  URLSession.shared.dataTask(with: url) { data, response, error in
		 DispatchQueue.main.async {
			self.isLoading = false

			if let error = error {
			   self.errorMessage = error.localizedDescription
			   return
			}

			guard let data = data else {
			   self.errorMessage = "No data received"
			   return
			}

			do {
			   let transactions = try JSONDecoder().decode([TransactionModel].self, from: data)

			   // Preload user data for each transaction creator
			   let group = DispatchGroup()
			   for transaction in transactions {
				  group.enter()
				  if self.userViewModels[transaction.creator] == nil {
					 let userViewModel = UserViewModel()
					 userViewModel.fetchUser(by: transaction.creator) {
						self.userViewModels[transaction.creator] = userViewModel
						group.leave()
					 }
				  } else {
					 group.leave()
				  }
			   }

			   group.notify(queue: .main) {
				  self.transactions = transactions
			   }
			} catch {
			   self.errorMessage = "Failed to decode transaction data"
			}
		 }
	  }.resume()
   }

   func getUserViewModel(for creatorID: String) -> UserViewModel? {
	  return userViewModels[creatorID]
   }
}
