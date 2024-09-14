import SwiftUI

@main
struct SleepThisApp: App {
   var body: some Scene {
	  WindowGroup {
		 TabView {

			LeagueListView(
			   draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID), // Pass leagueID here
			   managerID: AppConstants.managerID // Ensure managerID is passed
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

			NFLRosterView()
			   .tabItem {
				  Label("NFL Roster", systemImage: "person.3.fill")
			   }
		 }
		 .preferredColorScheme(.dark)
		 .showVersionNumber()
	  }
   }
}
