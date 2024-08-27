import SwiftUI

struct TransactionDetailView: View {
   let transactionModel: TransactionModel
   var userViewModel = UserViewModel()
   var playerViewModel = PlayerViewModel()

   var body: some View {
	  VStack(alignment: .leading) {
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

		 // Handling Adds
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

		 // Handling Drops
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

		 // Handling Draft Picks
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
