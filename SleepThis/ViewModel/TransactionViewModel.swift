import Foundation
import Combine

class TransactionViewModel: ObservableObject {
   @Published var transactions: [TransactionModel] = []
   @Published var isLoading = false
   @Published var errorMessage: String?

   func fetchTransactions(leagueID: String, round: Int) {
	  isLoading = true
	  // Implement your transaction fetching logic here
	  fetchTransactionsFromAPI(leagueID: leagueID, round: round) { result in
		 DispatchQueue.main.async {
			self.isLoading = false
			switch result {
			   case .success(let transactions):
				  self.transactions = transactions
			   case .failure(let error):
				  self.errorMessage = error.localizedDescription
			}
		 }
	  }
   }

   private func fetchTransactionsFromAPI(leagueID: String, round: Int, completion: @escaping (Result<[TransactionModel], Error>) -> Void) {
	  // Implement the API fetching logic here
	  // Example: completion(.success(mockTransactions))
   }
}
