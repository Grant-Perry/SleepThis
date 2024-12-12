import SwiftUI

struct FantasyGameMatchupView: View {
   @ObservedObject var gameMatchupViewModel: FantasyGameMatchupViewModel

   var body: some View {
	  VStack(alignment: .leading, spacing: 1) {
		 HStack(spacing: 4) {
			Text("\(gameMatchupViewModel.awayTeamAbbrev)")
			   .font(.system(size: 10))
			   .fontWeight(.bold)
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
			   .scaledToFit()

			Text("vs")
			   .font(.system(size: 8))
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
			   .scaledToFit()

			Text("\(gameMatchupViewModel.homeTeamAbbrev)")
			   .font(.system(size: 10))
			   .fontWeight(.bold)
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
			   .scaledToFit()

			Text("\(gameMatchupViewModel.awayScore)-\(gameMatchupViewModel.homeScore)")
			   .font(.system(size: 10))
			   .fontWeight(.semibold)
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
			   .scaledToFit()
		 }

		 Text(gameMatchupViewModel.quarterTime.isEmpty ? "Final" : gameMatchupViewModel.quarterTime)
			.font(.system(size: 8))
			.foregroundColor(.secondary)
			.lineLimit(1)
			.minimumScaleFactor(0.5)
			.scaledToFit()
			.padding(.leading, 0)

		 Text(gameMatchupViewModel.dayTime)
			.font(.system(size: 8))
			.foregroundColor(.secondary)
			.lineLimit(1)
			.minimumScaleFactor(0.5)
			.scaledToFit()
			.padding(.leading, 0)
	  }
   }
}
