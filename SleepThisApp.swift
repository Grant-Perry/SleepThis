import SwiftUI

@main
struct SleepThisApp: App {
   var body: some Scene {
	  WindowGroup {
		 TabView {

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

			ManagerListView(
			   draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID),
			   rosterViewModel: RosterViewModel(leagueID: AppConstants.leagueID, draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID)),
			   leagueID: AppConstants.leagueID,
			   draftID: AppConstants.draftID,
			   viewType: .roster
			)
			.tabItem {
			   Label("Rosters", systemImage: "pencil.and.list.clipboard")
			}

			ManagerListView(
			   draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID),
			   rosterViewModel: RosterViewModel(leagueID: AppConstants.leagueID, draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID)),
			   leagueID: AppConstants.leagueID,
			   draftID: AppConstants.draftID,
			   viewType: .draft
			)
			.tabItem {
			   Label("Draft", systemImage: "list.clipboard")
			}

			PlayerSearchView()
			   .tabItem {
				  Label("Player Search", systemImage: "plus.magnifyingglass")
			   }


		 }
		 .preferredColorScheme(.dark)
		 .showVersionNumber()
	  }
   }
}
