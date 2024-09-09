import SwiftUI

struct ManagerRowView: View {
   let managerID: String
   @ObservedObject var draftViewModel: DraftViewModel
   let backgroundColor: Color
   let viewType: ManagerViewType

   var body: some View {
	  LazyVStack{
	     NavigationLink(destination: destinationView) {
		   HStack {
			   // Manager's avatar
			   if let avatarURL = draftViewModel.managerAvatar(for: managerID) {
				  AsyncImage(url: avatarURL) { image in
					 image.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: 60, height: 60)
						.clipShape(Circle())
						.padding(.leading, 16)
				  } placeholder: {
					 Image(systemName: "person.crop.circle")
						.resizable()
						.frame(width: 60, height: 60)
						.padding(.leading, 16)
				  }
			   } else {
				  Image(systemName: "person.crop.circle")
					 .resizable()
					 .frame(width: 60, height: 60)
					 .padding(.leading, 16)
			   }

			   // Manager's name and draft pick
			   VStack(alignment: .leading) {
				  Text(draftViewModel.managerName(for: managerID))
					 .font(.title2)
					 .bold()
				  if let draftSlot = draftViewModel.groupedPicks[managerID]?.first?.draft_slot {
					 Text("Draft Pick #:\(draftSlot)")
						.font(.caption2)
						.foregroundColor(.gray)
						.padding(.leading, 10)
				  } else {
					 Text("Pick #: N/A")
						.font(.subheadline)
						.padding(.leading, 10)
				  }
			   }

			   Spacer()
			}
			.padding(.vertical, 15)  // Vertical padding for card height
			.padding(.horizontal, 16)  // Horizontal padding inside the card
			.background(
			   RoundedRectangle(cornerRadius: 15)  // Rounded corners
				  .fill(backgroundColor)
				  .shadow(radius: 4)
			)
			.padding(.vertical, 4)  // Padding between the cards
			.padding(.horizontal, 4)  // Padding to prevent cards from touching screen edges
		 }
	  }
   }

   // Dynamic destination view based on the view type
   @ViewBuilder
   var destinationView: some View {
	  if viewType == .draft {
		 if let draftPick = draftViewModel.groupedPicks[managerID]?.first {
			DraftListView(managerID: managerID, draftViewModel: draftViewModel)
		 } else {
			Text("No Draft Pick Available")
		 }
	  } else {
		 let managerName = draftViewModel.managerName(for: managerID)
		 let managerAvatarURL = draftViewModel.managerAvatar(for: managerID)
		 RosterDetailView(managerID: managerID, managerName: managerName, managerAvatarURL: managerAvatarURL, rosterViewModel: RosterViewModel(leagueID: AppConstants.leagueID))
	  }
   }
}
