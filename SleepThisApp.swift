import SwiftUI
import Combine

@main
struct SleepThisApp: App {
   var body: some Scene {
	  WindowGroup {
		 TabView {
			FantasyMatchupListView()
			   .tabItem {
				  Label("Fantasy", systemImage: "fan.oscillation")
			   }

			LivePlayerListView()
			   .tabItem {
				  Label("LIVE", systemImage: "livephoto.play")
			   }

			PlayerSearchView(nflRosterViewModel: NFLRosterViewModel())
			   .tabItem {
				  Label("Player Search", systemImage: "plus.magnifyingglass")
			   }

			LeagueListView(
			   managerID: AppConstants.managerID,
			   draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID)
			)
			.tabItem {
			   Label("League", systemImage: "list.bullet.rectangle")
			}

			NFLTeamListView()
			   .tabItem {
				  Label("NFL Roster", systemImage: "person.3.fill")
			   }

			ManagerListView(
			   leagueID: AppConstants.leagueID,
			   draftID: AppConstants.draftID,
			   viewType: .roster,
			   draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID),
			   rosterViewModel: RosterViewModel(leagueID: AppConstants.leagueID,
												draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID))
			)
			.tabItem {
			   Label("Rosters", systemImage: "pencil.and.list.clipboard")
			}

			ManagerListView(
			   leagueID: AppConstants.leagueID,
			   draftID: AppConstants.draftID,
			   viewType: .draft,
			   draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID),
			   rosterViewModel: RosterViewModel(leagueID: AppConstants.leagueID,
												draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID))
			)
			.tabItem {
			   Label("Draft", systemImage: "dice")
			}

		 }
		 .preferredColorScheme(.dark)
		 .showVersionNumber()
	  }
   }
}
