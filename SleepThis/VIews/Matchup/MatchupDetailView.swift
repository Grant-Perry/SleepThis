import SwiftUI

struct MatchupDetailView: View {
   let matchup: MatchupModel
   var playerViewModel = PlayerViewModel()

   var body: some View {
	  VStack(alignment: .leading) {
		 Text("Matchup ID: \(matchup.matchup_id)")
			.font(.headline)

		 if !matchup.starters.isEmpty {
			let playerNames = playerViewModel.getPlayerNames(from: matchup.starters)
			Text("Starters: \(playerNames)")
		 } else {
			Text("No starters available.")
		 }

		 if !matchup.players.isEmpty {
			let playerNames = playerViewModel.getPlayerNames(from: matchup.players)
			Text("Players: \(playerNames)")
		 } else {
			Text("No players available.")
		 }

		 Spacer()
	  }
	  .padding()
	  .navigationTitle("Matchup Details")
   }
}
