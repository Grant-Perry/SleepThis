import SwiftUI

struct TransactionView: View {
   @ObservedObject private var transactionViewModel = TransactionViewModel()

   @State private var week: String = "1"
   private let leagueID = AppConstants.leagueID

   var body: some View {
	  NavigationStack {
		 VStack {
			if transactionViewModel.isLoading {
			   ProgressView("LOADING DATA...")
				  .padding()
			} else if transactionViewModel.transactions.isEmpty {
			   Text("No transactions data available.")
				  .foregroundColor(.red)
			} else {
			   List(transactionViewModel.transactions, id: \.transaction_id) { transaction in
				  if let userViewModel = transactionViewModel.getUserViewModel(for: transaction.creator) {
					 NavigationLink(
						destination: TransactionDetailView(transaction: transaction, userViewModel: userViewModel)
					 ) {
						TransactionRowView(transaction: transaction, userViewModel: userViewModel)
					 }
				  }
			   }
			}
		 }
		 .onAppear {
			transactionViewModel.fetchTransactions(leagueID: leagueID, round: Int(week) ?? 1)
		 }
		 .navigationTitle("Transactions")
	  }
   }
}
