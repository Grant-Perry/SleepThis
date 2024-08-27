import Foundation
import Combine

class TransactionViewModel: ObservableObject {
   @Published var transactions: [TransactionModel] = []
   @Published var isLoading = false
   @Published var errorMessage: String?
	var userViewModel: [String: UserViewModel] = [:]

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
			   self.transactions = transactions
			   // Preload User ViewModels
			   for transaction in transactions {
				  if self.userViewModel[transaction.creator] == nil {
					 let userViewModel = UserViewModel()
					 userViewModel.fetchUser(by: transaction.creator)
					 self.userViewModel[transaction.creator] = userViewModel
				  }
			   }
			} catch {
			   self.errorMessage = "Failed to decode transaction data"
			}
		 }
	  }.resume()
   }

   func getUserViewModel(for creatorID: String) -> UserViewModel? {
	  return userViewModel[creatorID]
   }
}
