import SwiftUI

struct MatchupDetailView: View {
   let matchup: MatchupModel
   @ObservedObject var playViewModel = PlayerViewModel()

   var body: some View {
	  VStack(alignment: .leading) {
		 Text("Matchup ID: \(matchup.matchup_id)")
			.font(.headline)

		 // Directly access the 'starters' array without optional binding
		 if !matchup.starters.isEmpty {
			let playerNames = playViewModel.getPlayerNames(from: matchup.starters)
			Text("Starters: \(playerNames)")
		 } else {
			Text("No starters available.")
		 }

		 // Directly access the 'players' array without optional binding
		 if !matchup.players.isEmpty {
			let playerNames = playViewModel.getPlayerNames(from: matchup.players)
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
