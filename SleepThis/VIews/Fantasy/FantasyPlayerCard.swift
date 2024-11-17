import SwiftUI

struct FantasyPlayerCard: View {
   let player: FantasyScores.FantasyModel.Team.PlayerEntry
   let fantasyViewModel: FantasyMatchupViewModel

   var body: some View {
	  VStack(spacing: 4) {
		 // Player Name at the top, full width
		 Text(player.playerPoolEntry.player.fullName)
			.font(.subheadline)
			.fontWeight(.medium)
			.frame(maxWidth: .infinity, alignment: .trailing)
			.lineLimit(1)

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
			.frame(width: 90, height: 90)
			.offset(x: -15, y: -25)

			VStack(alignment: .leading, spacing: 4) {
			   Text(fantasyViewModel.positionString(player.lineupSlotId))
				  .font(.caption)
				  .foregroundColor(.secondary)
			}

			Spacer()

			let score = fantasyViewModel.getPlayerScore(for: player, week: fantasyViewModel.selectedWeek)
			Group {
			   if score == 0 {
				  Text("0")
					 .font(.system(size: 16, weight: .medium))
					 .foregroundColor(.gpGray)
			   } else {
				  Text(String(format: "%.2f", score))
					 .font(.system(size: 20, weight: .bold))
					 .foregroundColor(.gpMinty)
			   }
			}
			.frame(maxWidth: .infinity)
			.lineLimit(1)
			.minimumScaleFactor(0.5)
			.scaledToFit()
		 }
		 .frame(height: 45) // Set explicit height for HStack to contain image overflow
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
	  .frame(height: 75) // Set explicit height for the entire card
   }
}
