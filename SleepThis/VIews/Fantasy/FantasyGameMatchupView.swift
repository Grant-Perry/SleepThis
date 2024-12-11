import SwiftUI

// A view that displays the game matchup info provided by FantasyGameMatchupViewModel.
struct FantasyGameMatchupView: View {
   @ObservedObject var gameMatchupViewModel: FantasyGameMatchupViewModel

   var body: some View {
	  VStack(alignment: .leading, spacing: 2) {
		 HStack {
			// Display matchup teams and scores
			Text("\(gameMatchupViewModel.awayTeamAbbrev) v \(gameMatchupViewModel.homeTeamAbbrev)")
			   .font(.footnote)
			   .fontWeight(.bold)
			Spacer()
			Text("\(gameMatchupViewModel.awayScore)-\(gameMatchupViewModel.homeScore)")
			   .font(.footnote)
			   .fontWeight(.semibold)
		 }

		 Text(gameMatchupViewModel.quarterTime)
			.font(.caption2)
			.foregroundColor(.secondary)

		 Text(gameMatchupViewModel.dayTime)
			.font(.caption2)
			.foregroundColor(.secondary)
	  }
	  .padding(4)
	  .background(Color(.systemGray6).opacity(0.4))
	  .cornerRadius(8)
   }
}
