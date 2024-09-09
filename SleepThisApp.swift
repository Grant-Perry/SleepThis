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

//			TransactionView()
//			   .tabItem {
//				  Label("Transactions", systemImage: "swatchpalette")
//			   }

//			RosterListView(rosterViewModel: RosterViewModel(leagueID: AppConstants.TwoBrothersID))

		 }
	  }
   }
}
