import SwiftUI

struct TransactionDetailView: View {
   let transaction: TransactionModel
   @ObservedObject var playerViewModel: PlayerViewModel

   var body: some View {
	  VStack(alignment: .leading) {
		 Text("Transaction ID: \(transaction.transaction_id)")
			.font(.headline)

		 Text("Type: \(transaction.type)")
			.font(.subheadline)

		 Text("Status: \(transaction.status)")
			.font(.subheadline)

		 if let adds = transaction.adds {
			let addedPlayerNames = playerViewModel.getPlayerNames(from: Array(adds.keys))
			Text("Added Players: \(addedPlayerNames)")
		 } else {
			Text("No players added.")
		 }

		 if let drops = transaction.drops {
			let droppedPlayerNames = playerViewModel.getPlayerNames(from: Array(drops.keys))
			Text("Dropped Players: \(droppedPlayerNames)")
		 } else {
			Text("No players dropped.")
		 }

		 Spacer()
	  }
	  .padding()
	  .navigationTitle("Transaction Details")
   }
}
