import SwiftUI

struct ManagerRowView: View {
   let managerID: String
   @ObservedObject var draftViewModel: DraftViewModel
   let backgroundColor: Color
   let viewType: ManagerViewType  // Enum to switch between draft and roster

   var body: some View {
	  HStack {
		 if let avatarURL = draftViewModel.managerAvatar(for: managerID) {
			AsyncImage(url: avatarURL) { image in
			   image.resizable()
				  .aspectRatio(contentMode: .fill)
				  .frame(width: 50, height: 50)
				  .clipShape(Circle())
			} placeholder: {
			   Image(systemName: "person.crop.circle")
				  .resizable()
				  .frame(width: 50, height: 50)
			}
		 } else {
			Image(systemName: "person.crop.circle")
			   .resizable()
			   .frame(width: 50, height: 50)
		 }

		 VStack(alignment: .leading) {
			Text(draftViewModel.managerName(for: managerID))
			   .font(.title2)
			   .bold()

			if let draftSlot = draftViewModel.groupedPicks[managerID]?.first?.draft_slot {
			   Text("Pick #:\(draftSlot)")
				  .font(.subheadline)
			} else {
			   Text("Pick #: N/A")
				  .font(.subheadline)
			}
		 }
	  }
	  .padding()
	  .background(backgroundColor)
	  .cornerRadius(8)
	  .foregroundColor(.black)

	  NavigationLink(destination: {
		 if viewType == .draft {
			if let draftPick = draftViewModel.groupedPicks[managerID]?.first {
			   DraftDetailView(managerID: managerID, draftPick: draftPick, draftViewModel: draftViewModel)
			} else {
			   Text("No Draft Pick Available")
			}
		 } else {
			RosterDetailView(managerID: managerID, rosterViewModel: RosterViewModel(leagueID: AppConstants.TwoBrothersID))
		 }
	  }) {
		 EmptyView()  // Invisible tap target, the whole row is tappable
	  }
   }
}
