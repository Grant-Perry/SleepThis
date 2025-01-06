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

			FantasyPlayerScores()
			   .tabItem {
				  Label("FanScore", systemImage: "atom")
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

			ManagerListView(
			   draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID),
			   rosterViewModel: RosterViewModel(leagueID: AppConstants.leagueID,
												draftViewModel: DraftViewModel(leagueID: AppConstants.leagueID)),
			   leagueID: AppConstants.leagueID,
			   draftID: AppConstants.draftID,
			   viewType: .draft
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
