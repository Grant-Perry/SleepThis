

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

//			UserSearchView()
//			   .tabItem {
//				  Label("User Search", systemImage: "magnifyingglass")
//			   }

			MatchupView()
			   .tabItem {
				  Label("Matchups", systemImage: "list.bullet")
			   }

			TransactionView()
			   .tabItem {
				  Label("Transactions", systemImage: "swatchpalette")
			   }
		 }
	  }
   }
}

