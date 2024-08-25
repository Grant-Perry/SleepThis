import Foundation
import Combine

class TransactionViewModel: ObservableObject {
   @Published var transactions: [TransactionModel] = []
   @Published var isLoading = false
   @Published var errorMessage: String?

   func fetchTransactions(leagueID: String, round: Int) {
	  isLoading = true

//	  let urlString = "https://api.sleeper.app/v1/league/1051207774316683264/transactions/1"
	  let urlString = "https://api.sleeper.app/v1/league/\(leagueID)/transactions/\(round)"
	  print("urlString: \(urlString)")
	  guard let url = URL(string: urlString) else {
		 self.errorMessage = "Invalid URL"
		 return
	  }

	  URLSession.shared.dataTask(with: url) { data, response, error in
		 DispatchQueue.main.async {
			self.isLoading = false

			if let error = error {
			   self.errorMessage = "\(error.localizedDescription), not kidding"
			   return
			}

			guard let data = data else {
			   self.errorMessage = "No data received, bitch"
			   return
			}

			do {
			   let transactions = try JSONDecoder().decode([TransactionModel].self, from: data)
			   self.transactions = transactions
			} catch {
			   self.errorMessage = "Failed to decode transaction data - ass"
			}
		 }
	  }.resume()
   }
}
