import SwiftUI

struct TransactionView: View {
  var transactionViewModel = TransactionViewModel()

   @State var week: String = "1"
   let leagueID = AppConstants.leagueID

   var body: some View {
	  NavigationStack {
		 VStack {
			Picker("Select Week", selection: $week) {
			   ForEach(1..<17) { week in
				  Text("Week \(week)").tag(String(week))
			   }
			}
			.pickerStyle(MenuPickerStyle())
			.padding()

			if transactionViewModel.isLoading {
			   ProgressView("LOADING DATA...")
				  .padding()
			} else if transactionViewModel.transactions.isEmpty {
			   Text("No transactions data available.")
				  .foregroundColor(.red)
			} else {
			   List(transactionViewModel.transactions, id: \.transaction_id) { transaction in
				  if let userViewModel = transactionViewModel.getUserViewModel(for: transaction.creator) {
					 NavigationLink(destination: TransactionDetailView(transactionModel: transaction,
																	   userViewModel: userViewModel)) {
						TransactionRowView(thisTransaction: transaction, thisUserViewModel: userViewModel)
					 }
				  }
			   }
			}
			Spacer()

			// Version Number in Safe Area
			Text("Version: \(AppConstants.getVersion())")
			   .font(.system(size: 9))
			   .foregroundColor(.teal)
			   .padding(.bottom, 2)
		 }
		 .onAppear {
			transactionViewModel.fetchTransactions(leagueID: leagueID, round: Int(week) ?? 1)
		 }
		 .navigationTitle("Transactions Week \(week)")
	  }
   }
}
