import SwiftUI

struct LeagueDetailView: View {
   @StateObject private var leagueDetailViewModel = LeagueDetailViewModel()
   let leagueID: String
   let draftID: String

   var body: some View {
	  VStack {
		 if let league = leagueDetailViewModel.league {
			Text(league.name)
			   .font(.largeTitle)
			Text(league.leagueID)
			   .font(.footnote)
			   .padding()

			Text("Season: \(league.season)")
			   .font(.title2)
			   .padding(.bottom)

			// Display other league details
			Text("Total Rosters: \(league.totalRosters)")
			   .font(.headline)
			   .padding(.bottom)

			// Navigation to Manager List
			NavigationLink(destination: ManagerListView(
			   draftViewModel: DraftViewModel(leagueID: leagueID),
			   rosterViewModel: RosterViewModel(leagueID: leagueID, draftViewModel: DraftViewModel(leagueID: leagueID)),
			   leagueID: leagueID,
			   draftID: draftID,
			   viewType: .roster
			)) {
			   Text("View Rosters")
				  .font(.headline)
				  .padding()
				  .frame(maxWidth: .infinity)
				  .background(Color.blue)
				  .foregroundColor(.white)
				  .cornerRadius(10)
				  .padding(.horizontal)
			}

			Spacer()
		 } else {
			ProgressView("Loading League Details...")
			   .onAppear {
				  leagueDetailViewModel.fetchLeague(leagueID: leagueID)
			   }
		 }
	  }
	  .navigationTitle("League Details")
   }
}
