import SwiftUI
import Combine

@main
struct SleepThisApp: App {
   var body: some Scene {
	  WindowGroup {
		 TabView {
			ESPNFantasyListView()
			   .tabItem {
				  Label("Fantasy", systemImage: "livephoto.play")
			   }

			LivePlayerListView()
			   .tabItem {
				  Label("LIVE", systemImage: "livephoto.play")
			   }

			PlayerSearchView(nflRosterViewModel: NFLRosterViewModel())
			   .tabItem {
				  Label("Player Search", systemImage: "plus.magnifyingglass")
			   }

			ManagerSwipeView(
			   draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID),
			   rosterViewModel: RosterViewModel(leagueID: AppConstants.leagueID,
												draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID)),
			   playerViewModel: PlayerViewModel()
			)
			.tabItem {
			   Label("Swipe", systemImage: "person.2.square.stack.fill")
			}

			ManagerListView(
			   draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID),
			   rosterViewModel: RosterViewModel(leagueID: AppConstants.leagueID,
												draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID)),
			   leagueID: AppConstants.leagueID,
			   draftID: AppConstants.draftID,
			   viewType: .roster
			)
			.tabItem {
			   Label("Rosters", systemImage: "pencil.and.list.clipboard")
			}

			NFLTeamListView()
			   .tabItem {
				  Label("NFL Roster", systemImage: "person.3.fill")
			   }

			LeagueListView(
			   managerID: AppConstants.managerID,
			   draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID)
			)
			.tabItem {
			   Label("League", systemImage: "list.bullet.rectangle")
			}
		 }
		 .preferredColorScheme(.dark)
		 .showVersionNumber()
	  }
   }
}
