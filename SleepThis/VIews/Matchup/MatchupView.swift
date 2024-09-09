import SwiftUI

struct MatchupView: View {
   var matchupViewModel = MatchupViewModel()

   @State  var week: String = "1"
   let leagueID = AppConstants.leagueID

   var body: some View {
	  NavigationView {
		 VStack {
			if matchupViewModel.isLoading {
			   ProgressView("Loading Matchups...")
				  .padding()
			} else if matchupViewModel.matchups.isEmpty {
			   Text("No matchups data available.")
				  .foregroundColor(.red)
			} else {
			   List(matchupViewModel.matchups) { matchup in
				  VStack(alignment: .leading) {
					 Text("Roster ID: \(matchup.roster_id)")
					 Text("Points: \(matchup.points)")
				  }
			   }
			}

			Spacer()
		 }
		 .navigationTitle("Matchups")
		 .onAppear {
			matchupViewModel.fetchMatchups(leagueID: leagueID, week: Int(week) ?? 1)
		 }
	  }
   }
}

