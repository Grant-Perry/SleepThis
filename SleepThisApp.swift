import SwiftUI

@main
struct SleepThisApp: App {
   var body: some Scene {
	  WindowGroup {
		 TabView {
			PlayerSearchView()
			   .tabItem {
				  Label("Player Search", systemImage: "plus.magnifyingglass")
			   }

			ManagerListView(draftViewModel: DraftViewModel(), viewType: .draft)

			   .tabItem {
				  Label("Draft", systemImage: "list.clipboard")
			   }

			ManagerListView(draftViewModel: DraftViewModel(), viewType: .roster)
			   .tabItem {
				  Label("Rosters", systemImage: "pencil.and.list.clipboard")
			   }

			NFLRosterView()  // Adding the NFL Roster tab
			   .tabItem {
				  Label("NFL Roster", systemImage: "person.3.fill")
			   }


//			TransactionView()
//			   .tabItem {
//				  Label("Transactions", systemImage: "swatchpalette")
//			   }

//			RosterListView(rosterViewModel: RosterViewModel(leagueID: AppConstants.TwoBrothersID))

		 }
	  }
   }
}
