import SwiftUI

struct FantasyGameMatchupView: View {
   @ObservedObject var gameMatchupViewModel: FantasyGameMatchupViewModel

   var body: some View {
	  let awayIsWinning = gameMatchupViewModel.awayScore > gameMatchupViewModel.homeScore
	  let homeIsWinning = gameMatchupViewModel.homeScore > gameMatchupViewModel.awayScore

	  VStack(alignment: .leading, spacing: 1) {
		 // HStack for Team Names and Scores
		 HStack(spacing: 0) {
			Text("\(gameMatchupViewModel.awayTeamAbbrev)")
			   .font(.system(size: 10))
			   .foregroundColor(awayIsWinning ? .gpGreen : .gpWhite)
			   .fontWeight(.bold)
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
			   .scaledToFit()

			Text(" vs. ")
			   .font(.system(size: 8))
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
			   .scaledToFit()

			Text("\(gameMatchupViewModel.homeTeamAbbrev): ")
			   .font(.system(size: 10))
			   .foregroundColor(homeIsWinning ? .gpGreen : .gpWhite)
			   .fontWeight(.bold)
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
			   .scaledToFit()
		 }
		 HStack {

			Text("\(gameMatchupViewModel.awayScore)")
			   .font(.system(size: 10))
			   .fontWeight(.semibold)
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
			   .scaledToFit()
			   .foregroundColor(awayIsWinning ? .gpGreen : .white)

			Text("-")
			   .font(.system(size: 10))
			   .fontWeight(.semibold)
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
			   .scaledToFit()

			Text("\(gameMatchupViewModel.homeScore)")
			   .font(.system(size: 10))
			   .fontWeight(.semibold)
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
			   .scaledToFit()
			   .foregroundColor(homeIsWinning ? .gpGreen : .white)

			// Line for Score Difference (awayScore - homeScore)
			Text("(\(abs(gameMatchupViewModel.awayScore - gameMatchupViewModel.homeScore)))")
			   .font(.system(size: 8))
			   .foregroundColor(.gpGreen)
			   .fontWeight(.semibold)

			   .padding(.trailing)
//			Spacer()
		 }
		 // Quarter Time or Final
		 Text(gameMatchupViewModel.quarterTime.isEmpty ? "Final" : gameMatchupViewModel.quarterTime)
			.font(.system(size: 8))
			.foregroundColor(.secondary)
			.lineLimit(1)
			.minimumScaleFactor(0.5)
			.scaledToFit()
			.padding(.leading, 0)

		 // Day and Time
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

