import SwiftUI

struct DraftListView: View {
   let managerID: String
   @StateObject var draftViewModel: DraftViewModel
   @StateObject var userViewModel = UserViewModel()
   @StateObject var playerViewModel = PlayerViewModel() // Add this line to instantiate PlayerViewModel
   let backgroundColor: Color

   var body: some View {
	  VStack {
		 if let user = userViewModel.user {
			// MARK: Manager's avatar and name
			HStack {
			   if let avatarURL = user.avatarURL {
				  AsyncImage(url: avatarURL) { image in
					 image.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: 60, height: 60)
						.clipShape(Circle())
				  } placeholder: {
					 Image(systemName: "person.crop.circle")
						.resizable()
						.frame(width: 50, height: 50)
				  }
			   }
			   VStack(alignment: .leading) {
				  Text(user.display_name ?? user.username)
					 .font(.title2)
					 .bold()

				  if let draftSlot = draftViewModel.groupedPicks[managerID]?.first?.draft_slot {
					 Text("Pick #: \(draftSlot)")
						.font(.subheadline)
						.padding(.trailing)
				  } else {
					 Text("")
						.font(.subheadline)
				  }
			   }
			   Spacer()
			}
			.frame(maxWidth: .infinity)
			.padding(.leading)
			.background(
			   RoundedRectangle(cornerRadius: 15)
				  .fill(LinearGradient(
					 gradient: Gradient(colors: [
						backgroundColor,
						backgroundColor.blended(withFraction: 0.55, of: .white)
					 ]),
					 startPoint: .top,
					 endPoint: .bottom
				  ))
				  .shadow(radius: 4)
			)
			.padding()
		 }

		 // List the draft picks for this manager
		 List {
			if let picks = draftViewModel.groupedPicks[managerID] {
			   ForEach(picks) { draft in
				  NavigationLink(
					 destination: DraftDetailView(
						managerID: managerID,
						draftPick: draft,
						draftViewModel: draftViewModel,
						playerViewModel: playerViewModel // Pass the playerViewModel here
					 )
				  ) {
					 DraftRowView(draft: draft,
								  draftViewModel: draftViewModel,
								  playerViewModel: playerViewModel
					 )
				  }
			   }
			} else {
			   Text("No picks available for this manager.")
			}
		 }
	  }
	  .navigationBarTitleDisplayMode(.inline)
	  .toolbar {
		 ToolbarItem(placement: .principal) {
			Text("Picks for \(draftViewModel.managerName(for: managerID))")
			   .font(.callout)
			   .bold()
		 }
	  }
	  .onAppear {
		 userViewModel.fetchUser(by: managerID) // Fetch the user info
	  }
   }
}
