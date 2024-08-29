import SwiftUI

struct TransactionView: View {
   var transactionViewModel = TransactionViewModel()

   @State var week: String = "1"
   @State private var leagueID: String = AppConstants.leagueID
   @State private var isSearching: Bool = false

   var body: some View {
	  NavigationStack {
		 VStack {
			// Text box for league ID input with label
			HStack {
			   Text("for league:")
				  .font(.subheadline)
				  .foregroundColor(.gray)

			   TextField("Enter League ID", text: $leagueID)
				  .textFieldStyle(RoundedBorderTextFieldStyle())
				  .padding(.horizontal)

			   Button(action: {
				  print("[TransactionView:searchLeague] Loading transactions for league ID: \(leagueID)")
				  isSearching = true
				  transactionViewModel.fetchTransactions(leagueID: leagueID, round: Int(week) ?? 1)
			   }) {
				  Image(systemName: "plus.magnifyingglass")
					 .font(.title2)
			   }
			}
			.padding()

			// Week Picker
			Picker("Select Week", selection: $week) {
			   ForEach(1..<17) { week in
				  Text("Week \(week)").tag(String(week))
			   }
			}
			.pickerStyle(MenuPickerStyle())
			.padding()

			// Transaction data handling
			if transactionViewModel.isLoading || isSearching {
			   ProgressView("Loading Transactions...")
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
			   .font(.system(size: AppConstants.verSize))
			   .foregroundColor(AppConstants.verColor)
//			   .padding(.bottom, 2)
		 }
		 .onAppear {
			transactionViewModel.fetchTransactions(leagueID: leagueID, round: Int(week) ?? 1)
		 }
		 .navigationTitle("Transactions Week \(week)")
	  }
   }
}
