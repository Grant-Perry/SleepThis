import SwiftUI

struct MatchupDetailView: View {
   let matchup: MatchupModel
   let playerViewModel: PlayerViewModel

   var body: some View {
	  ScrollView {
		 VStack(alignment: .leading, spacing: 10) {
			Text("Matchup ID: \(matchup.matchup_id)")
			   .font(.title)
			Text("Points: \(matchup.points)")
			Text("Starters: \(playerViewModel.getPlayerNames(from: matchup.starters))")
			Text("Bench: \(playerViewModel.getPlayerNames(from: matchup.players.filter { !matchup.starters.contains($0) }))")
			Spacer()
		 }
		 .padding()
		 .navigationTitle("Matchup Details")
	  }
   }
}
