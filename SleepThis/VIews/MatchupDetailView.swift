import SwiftUI

struct MatchupDetailView: View {
   let thisMatchup: MatchupModel
   var playerViewModel = PlayerViewModel()

   var body: some View {
	  VStack(alignment: .leading) {
		 Text("Matchup ID: \(thisMatchup.matchup_id)")
			.font(.headline)

		 if !thisMatchup.starters.isEmpty {
			let playerNames = playerViewModel.getPlayerNames(from: thisMatchup.starters)
			Text("Starters: \(playerNames)")
		 } else {
			Text("No starters available.")
		 }

		 if !thisMatchup.players.isEmpty {
			let playerNames = playerViewModel.getPlayerNames(from: thisMatchup.players)
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
