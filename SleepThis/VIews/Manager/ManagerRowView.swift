import SwiftUI

struct ManagerRowView: View {
   let managerID: String
   let leagueID: String
   @StateObject var draftViewModel: DraftViewModel
   let thisBackgroundColor: Color
   let viewType: ManagerViewType
   @State private var showRosterDetailView = false
   @State private var showLeagueListView = false

   var body: some View {
	  LazyVStack {
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
			   // Use a Button to navigate to RosterDetailView
			   Button(action: {
				  showRosterDetailView = true
			   }) {
				  Text(draftViewModel.managerName(for: managerID))
					 .font(.title2)
					 .foregroundColor(.gpDark2)
					 .bold()
			   }

			   // Use a Button for managerID to present LeagueListView
			   Button(action: {
				  showLeagueListView = true
			   }) {
				  Text("\(managerID)")
					 .font(.footnote)
					 .foregroundColor(.blue)
			   }

			   if let draftSlot = draftViewModel.groupedPicks[managerID]?.first?.draft_slot {
				  Text("Draft Pick #:\(draftSlot)")
					 .font(.caption2)
					 .foregroundColor(.gpDark1)
					 .padding(.leading, 10)
			   } else {
				  Text("Pick #: N/A")
					 .font(.subheadline)
					 .padding(.leading, 10)
			   }
			}

			Spacer()
		 }
		 .padding(.vertical, 15)
		 .padding(.horizontal, 16)
		 .background(
			RoundedRectangle(cornerRadius: 15)
			   .fill(LinearGradient(
				  gradient: Gradient(colors: [
					 thisBackgroundColor,
					 thisBackgroundColor.blended(withFraction: 0.55, of: .white)
				  ]),
				  startPoint: .top,
				  endPoint: .bottom
			   ))
			   .shadow(radius: 4)
		 )
		 .padding(.vertical, 4)
		 .padding(.horizontal, 4)
	  }
	  // Navigate to RosterDetailView when showRosterDetailView is true
	  .background(
		 NavigationLink(destination: destinationView, isActive: $showRosterDetailView) {
			EmptyView()
		 }
			.hidden()
	  )
	  // Present LeagueListView as a sheet
	  .sheet(isPresented: $showLeagueListView) {
		 LeagueListView(
			managerID: managerID,
			draftViewModel: draftViewModel
		 )
	  }
   }

   // Dynamic destination view based on the view type
   @ViewBuilder
   var destinationView: some View {
	  if viewType == .draft {
		 DraftListView(
			managerID: managerID,
			draftViewModel: draftViewModel,
			backgroundColor: thisBackgroundColor
		 )
	  } else {
		 let managerName = draftViewModel.managerName(for: managerID)
		 let managerAvatarURL = draftViewModel.managerAvatar(for: managerID)

		 RosterDetailView(
			leagueID: leagueID,
			managerID: managerID,
			managerName: managerName,
			managerAvatarURL: managerAvatarURL,
			draftViewModel: draftViewModel //,
//			rosterViewModel: RosterViewModel(leagueID: leagueID, draftViewModel: draftViewModel)
		 )
		 .preferredColorScheme(.dark)
	  }
   }
}
