import SwiftUI

struct ManagerSwipeView: View {
   @StateObject var draftViewModel: DraftViewModel

   var body: some View {
	  VStack {
		 if draftViewModel.managers.isEmpty {
			// Show a loading indicator if no managers are available
			ProgressView("Loading Managers...")
			   .onAppear {
				  // Fetch manager details for the league
				  draftViewModel.fetchAllManagerDetails()
			   }
		 } else {
			// Display TabView for swiping between ManagerListViews
			TabView {
			   ForEach(draftViewModel.managers, id: \.user_id) { manager in
				  ManagerListView(
					 draftViewModel: draftViewModel,
					 rosterViewModel: RosterViewModel(leagueID: draftViewModel.leagueID, draftViewModel: draftViewModel),
					 leagueID: draftViewModel.leagueID,
					 draftID: "draft_id_placeholder",  // Placeholder: Update as needed
					 viewType: .roster // Set viewType based on requirements
				  )
				  .tabItem {
					 // Optional: Show manager's name or avatar in the tab indicator
					 Text(manager.display_name ?? manager.username)
				  }
			   }
			}
			.tabViewStyle(PageTabViewStyle())
		 }
	  }
   }
}

// Preview for testing purposes
struct ManagerSwipeView_Previews: PreviewProvider {
   static var previews: some View {
	  ManagerSwipeView(draftViewModel: DraftViewModel(leagueID: "sample_league_id"))
   }
}
