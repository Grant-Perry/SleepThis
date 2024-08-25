import SwiftUI

struct TransactionView: View {
   @ObservedObject private var viewModel = TransactionViewModel()
   @ObservedObject private var playerViewModel = PlayerViewModel()

   @State private var week: String = "1"
   private let leagueID = AppConstants.leagueID

   var body: some View {
	  NavigationView {
		 VStack {
			if viewModel.isLoading {
			   ProgressView("LOADING DATA...")
				  .padding()
			} else if viewModel.transactions.isEmpty {
			   Text("No transactions data available.")
				  .foregroundColor(.red)
			} else {
			   List(viewModel.transactions) { transaction in
				  NavigationLink(
					 destination: TransactionDetailView(transaction: transaction, playerViewModel: playerViewModel)
				  ) {
					 VStack(alignment: .leading) {
						Text("Type: \(transaction.type)")
						   .font(.headline)
						Text("Status: \(transaction.status)")
						   .font(.subheadline)
					 }
				  }
			   }
			}
		 }
		 .onAppear {
			viewModel.fetchTransactions(leagueID: leagueID, round: Int(week) ?? 1) // Correct method call with parameters
		 }
		 .navigationTitle("Transactions")
	  }
   }
}
