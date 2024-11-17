import SwiftUI

struct FantasyPlayerCard: View {
   let player: FantasyScores.FantasyModel.Team.PlayerEntry
   let fantasyViewModel: FantasyMatchupViewModel

   var body: some View {
	  HStack {
		 // Player Image
		 Group {
			if fantasyViewModel.leagueID == AppConstants.ESPNLeagueID {
			   LivePlayerImageView(
				  playerID: player.playerPoolEntry.player.id,
				  picSize: 80
			   )
			   .scaledToFit()
			} else {
			   AsyncImage(
				  url: URL(string: "https://sleepercdn.com/content/nfl/players/\(player.playerPoolEntry.player.id).jpg")
			   ) { phase in
				  switch phase {
					 case .empty:
						Image(systemName: "person.circle.fill")
						   .resizable()
						   .scaledToFit()
						   .foregroundColor(.gray)
					 case .success(let image):
						image
						   .resizable()
						   .scaledToFit()
					 case .failure:
						Image(systemName: "person.circle.fill")
						   .resizable()
						   .scaledToFit()
						   .foregroundColor(.gray)
					 @unknown default:
						EmptyView()
				  }
			   }
			}
		 }
		 .frame(width: 80, height: 80)

		 VStack(alignment: .leading, spacing: 4) {
			Text(player.playerPoolEntry.player.fullName)
			   .font(.subheadline)
			   .fontWeight(.medium)
			   .lineLimit(1)

			Text(fantasyViewModel.positionString(player.lineupSlotId))
			   .font(.caption)
			   .foregroundColor(.secondary)
		 }

		 Spacer()

		 let score = fantasyViewModel.getPlayerScore(for: player, week: fantasyViewModel.selectedWeek)
		 Group {
			if score == 0 {
			   Text("0")
				  .font(.system(size: 16, weight: .semibold, design: .monospaced))
				  .foregroundColor(.secondary)
			} else {
			   Text(String(format: "%.2f", score))
				  .font(.headline)
				  .foregroundColor(.gpBlue)
			}
		 }
	  }
	  .padding(12)
	  .background(
		 LinearGradient(
			gradient: Gradient(colors: [Color(.secondarySystemBackground), Color.clear]),
			startPoint: .top,
			endPoint: .bottom
		 )
	  )
	  .cornerRadius(12)
	  .shadow(color: .black.opacity(0.05), radius: 2)
   }
}
