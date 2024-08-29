import SwiftUI

struct TransactionDetailView: View {
   let transactionModel: TransactionModel
   var userViewModel = UserViewModel()
   var playerViewModel = PlayerViewModel()

   var body: some View {
	  VStack(alignment: .leading) {
		 // Transaction ID and Type
		 Text("Transaction ID: \(transactionModel.id)")
			.font(.headline)
		 Text("Type: \(transactionModel.type)")
			.font(.subheadline)

		 // Creator Information
		 HStack {
			if let user = userViewModel.user {
			   if let avatarURL = user.avatarURL {
				  AsyncImage(url: avatarURL) { image in
					 image.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: 40, height: 40)
						.clipShape(Circle())
				  } placeholder: {
					 Image(systemName: "person.crop.circle")
						.resizable()
						.frame(width: 40, height: 40)
				  }
			   }

			   VStack(alignment: .leading) {
				  Text("Creator: \(user.display_name ?? "Unknown")")
					 .font(.body)
			   }
			} else {
			   Text("Creator: \(transactionModel.creator)")
				  .font(.body)
			}
		 }

		 // Adds Section
		 if let adds = transactionModel.adds {
			Text("Added Players:")
			   .font(.headline)
			ForEach(adds.keys.sorted(), id: \.self) { playerID in
			   if let player = playerViewModel.players.first(where: { $0.id == playerID }) {
				  Text("\(player.firstName ?? "Unknown") \(player.lastName ?? "Unknown") (\(player.team ?? "Unknown Team"))")
					 .font(.subheadline)
			   } else {
				  Text("Player ID \(playerID)")
					 .font(.subheadline)
			   }
			}
		 }

		 // Drops Section
		 if let drops = transactionModel.drops {
			Text("Dropped Players:")
			   .font(.headline)
			ForEach(drops.keys.sorted(), id: \.self) { playerID in
			   if let player = playerViewModel.players.first(where: { $0.id == playerID }) {
				  Text("\(player.firstName ?? "Unknown") \(player.lastName ?? "Unknown") (\(player.team ?? "Unknown Team"))")
					 .font(.subheadline)
			   } else {
				  Text("Player ID \(playerID)")
					 .font(.subheadline)
			   }
			}
		 } else {
			Text("No players dropped.")
			   .font(.subheadline)
		 }

		 // Draft Picks Section
		 if let draftPicks = transactionModel.draft_picks, !draftPicks.isEmpty {
			Text("Draft Picks:")
			   .font(.headline)
			ForEach(draftPicks, id: \.round) { pick in
			   Text("Round: \(pick.round ?? 0), Season: \(pick.season ?? "Unknown")")
				  .font(.subheadline)
			}
		 } else {
			Text("No draft picks")
			   .font(.subheadline)
		 }

		 // Waiver Budget Section
		 if let waiverBudgets = transactionModel.waiver_budget, !waiverBudgets.isEmpty {
			Text("Waiver Budgets:")
			   .font(.headline)
			ForEach(waiverBudgets.indices, id: \.self) { index in
			   let budget = waiverBudgets[index]
			   Text("Sender: \(budget.sender?.description ?? "Unknown"), Receiver: \(budget.receiver?.description ?? "Unknown"), Amount: \(budget.amount?.description ?? "Unknown")")
				  .font(.subheadline)
			}
		 } else {
			Text("No waiver budget transactions")
			   .font(.subheadline)
		 }

		 // Metadata Section
		 if let metadata = transactionModel.metadata {
			Text("Metadata:")
			   .font(.headline)
			Text("Notes: \(metadata.notes ?? "None")")
			   .font(.subheadline)
		 }

		 // Settings Section
		 if let settings = transactionModel.settings {
			Text("Settings:")
			   .font(.headline)
			Text("Priority: \(settings.priority?.description ?? "Unknown")")
			   .font(.subheadline)
			Text("Sequence: \(settings.seq?.description ?? "Unknown")")
			   .font(.subheadline)
			Text("Waiver Bid: \(settings.waiver_bid?.description ?? "Unknown")")
			   .font(.subheadline)
		 }

		 Spacer()
	  }
	  .padding()
	  .onAppear {
		 userViewModel.fetchUser(by: transactionModel.creator) {
			// Any additional code to run after fetching the user
		 }
	  }
   }
}
