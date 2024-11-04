import SwiftUI

struct ESPNFantasyPlayerView: View {
   let playerEntry: FantasyScores.FantasyModel.Team.PlayerEntry
   let week: Int
   @State private var lastScore: Double? = nil

   var body: some View {
	  VStack(spacing: 8) {
		 VStack(alignment: .leading, spacing: 4) {
			Text(playerEntry.playerPoolEntry.player.fullName)
			   .font(.body)
			   .bold()
			   .frame(maxWidth: .infinity, alignment: .leading)
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
		 }
		 .background(LinearGradient(gradient: Gradient(colors: [.gpDeltaPurple.opacity(0.2), .clear]), startPoint: .top, endPoint: .bottom))

		 HStack(spacing: 5) {
			// Player Thumbnail
			LivePlayerImageView(playerID: playerEntry.playerPoolEntry.player.id, picSize: 65)
			   .frame(width: 65, height: 65)

			VStack(alignment: .leading, spacing: 2) {
			   let currentScore = playerEntry.playerPoolEntry.player.stats.first { $0.scoringPeriodId == week && $0.statSourceId == 0 }?.appliedTotal ?? 0

			   // Position
			   Text(positionString(playerEntry.lineupSlotId))
				  .font(.system(size: 10, weight: .light))
				  .foregroundColor(.primary)
				  .frame(maxWidth: .infinity, alignment: .leading)
				  .padding(.top, 5)

			   // Score
			   Text("\(currentScore, specifier: "%.2f")")
				  .font(.system(size: 30, weight: .medium))
				  .foregroundColor(.secondary)
				  .frame(maxWidth: .infinity)
				  .lineLimit(1)
				  .minimumScaleFactor(0.5)
				  .scaledToFit()
				  .padding(.trailing)
				  .offset(x: 8)

			   // Last Play amount
			   Text("+/- \(currentScore - (lastScore ?? currentScore), specifier: "%.2f")")
				  .font(.system(size: 12, weight: .light))
				  .foregroundColor(currentScore - (lastScore ?? 0) > 0 ? .gpGreen : .gpRedPink)
				  .offset(x: 8)
			}
		 }
		 .frame(height: 60)
		 .padding(.vertical, 2)
		 .background(LinearGradient(gradient: Gradient(colors: [.gpDark1, .clear]), startPoint: .top, endPoint: .bottom))
		 .cornerRadius(8)
		 .onAppear {
			lastScore = playerEntry.playerPoolEntry.player.stats.first { $0.scoringPeriodId == week && $0.statSourceId == 0 }?.appliedTotal
		 }
	  }
   }

   func positionString(_ lineupSlotId: Int) -> String {
	  switch lineupSlotId {
		 case 0: return "QB"
		 case 2, 3: return "RB"
		 case 4, 5: return "WR"
		 case 6: return "TE"
		 case 16: return "D/ST"
		 case 17: return "K"
		 case 23: return "FLEX"
		 default: return ""
	  }
   }
}
