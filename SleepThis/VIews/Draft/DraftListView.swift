import SwiftUI

struct DraftListView: View {
   let managerID: String
   @ObservedObject var draftViewModel: DraftViewModel
   @ObservedObject var userViewModel = UserViewModel()  // Assuming this fetches user info

   var body: some View {
	  VStack {
		 if let user = userViewModel.user {
			// Display the manager's avatar and name
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
					 Text("Pick #: N/A")
						.font(.subheadline)
				  }
			   }
			}
			.padding()
		 }

		 // List the draft picks for this manager
		 List {
			if let picks = draftViewModel.groupedPicks[managerID] {
			   ForEach(picks) { draft in
				  NavigationLink(
					 destination: DraftDetailView(managerID: managerID,
												  draftPick: draft,
												  draftViewModel: draftViewModel)  // Pass managerID, draftPick, and draftViewModel
				  ) {
					 DraftRowView(draft: draft)
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
		 userViewModel.fetchUser(by: managerID)  // Fetch the user info
	  }
   }
}
