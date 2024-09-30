import SwiftUI

struct ManagerSwipeView: View {
   @StateObject var draftViewModel: DraftViewModel
   @StateObject var rosterViewModel: RosterViewModel
   @StateObject var playerViewModel: PlayerViewModel

   @State private var selectedManagerID: String = ""
   @State private var selectedManagerName: String = ""

   var body: some View {
	  TabView {
		 ForEach(rosterViewModel.rosters, id: \.ownerID) { roster in
			if let managerDetails = draftViewModel.managerDetails[roster.ownerID] {
			   VStack {
				  Text(managerDetails.name)
					 .font(.largeTitle)
					 .padding()

				  // Displaying RosterDetailView for each manager
				  RosterDetailView(
					 leagueID: rosterViewModel.leagueID,
					 managerID: roster.ownerID,
					 managerName: managerDetails.name,
					 managerAvatarURL: draftViewModel.managerAvatar(for: roster.ownerID),
					 draftViewModel: draftViewModel
				  )
			   }
			   .padding()
			   .tag(roster.ownerID)
			}
		 }
	  }
	  .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
	  .onAppear {
		 // Fetch data needed for displaying the manager's rosters and draft details
		 draftViewModel.fetchAllManagerDetails { success in
			if success {
			   print("[ManagerSwipeView]: Successfully fetched all manager details.")
			} else {
			   print("[ManagerSwipeView]: Failed to fetch some manager details.")
			}
		 }

		 rosterViewModel.fetchRoster()
		 playerViewModel.loadPlayersFromCache()
	  }
   }
}
