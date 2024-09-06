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

			ManagerListView(draftViewModel: DraftViewModel())
			   .tabItem {
				  Label("Draft", systemImage: "list.clipboard")
			   }

//			MatchupView()
//			   .tabItem {
//				  Label("Matchups", systemImage: "list.bullet")
//			   }

//			TransactionView()
//			   .tabItem {
//				  Label("Transactions", systemImage: "swatchpalette")
//			   }

			RosterListView(rosterViewModel: RosterViewModel(leagueID: AppConstants.TwoBrothersID))
			   .tabItem {
				  Label("Rosters", systemImage: "pencil.and.list.clipboard")
			   }
		 }
	  }
   }
}
