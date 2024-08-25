import SwiftUI

struct MatchupView: View {
   @ObservedObject var playViewModel = PlayerViewModel()

   @State private var week: String = "1"
   private let leagueID = AppConstants.leagueID  

   var body: some View {
	  NavigationView {
		 VStack {
			if let cacheAge = playViewModel.cacheAgeDescription {
			   Text("Cache Age: \(cacheAge)")
				  .font(.caption)
				  .padding(.bottom, 10)
			} else {
			   Text("Cache Age: Not available")
				  .font(.caption)
				  .foregroundColor(.gray)
				  .padding(.bottom, 10)
			}

			if playViewModel.isLoading {
			   ProgressView("Loading Matchups...")
				  .padding()
			} else if playViewModel.matchups.isEmpty {
			   Text("No matchups data available.")
				  .foregroundColor(.red)
			} else {
			   List(playViewModel.matchups) { matchup in
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
			playViewModel.fetchMatchups(leagueID: leagueID, week: Int(week) ?? 1)
		 }
	  }
   }
}
