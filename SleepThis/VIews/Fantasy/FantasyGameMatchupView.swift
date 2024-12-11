import SwiftUI

// A view that displays the game matchup info provided by FantasyGameMatchupViewModel.
struct FantasyGameMatchupView: View {
   @ObservedObject var gameMatchupViewModel: FantasyGameMatchupViewModel

   var body: some View {
	  VStack(alignment: .leading, spacing: 2) {
		 HStack {
			// Display matchup teams and scores
			Text("\(gameMatchupViewModel.awayTeamAbbrev)")
			   .font(.system(size: 12))
			   .fontWeight(.bold)
+
			Text(" VS ")
			   .font(.system(size: 8)) +

			Text("\(gameMatchupViewModel.homeTeamAbbrev)")
			   .font(.system(size: 12))
			   .fontWeight(.bold)
			Spacer()
			Text("\(gameMatchupViewModel.awayScore)-\(gameMatchupViewModel.homeScore)")
			   .font(.footnote)
			   .fontWeight(.semibold)
		 }
		 .opacity(0.7)

		 Text(gameMatchupViewModel.quarterTime)
			.font(.caption2)
			.foregroundColor(.secondary)

		 Text(gameMatchupViewModel.dayTime)
			.font(.caption2)
			.foregroundColor(.secondary)
	  }
	  .padding(4)
	  .offset(x: 55, y: 0)
	  //	  .background(Color(.systemGray6).opacity(0.4))
	  .cornerRadius(8)
   }
}
