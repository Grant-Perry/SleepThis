import SwiftUI

struct FantasyPlayerCard: View {
   let player: FantasyScores.FantasyModel.Team.PlayerEntry
   let fantasyViewModel: FantasyMatchupViewModel
   @State private var teamColor: Color = .gray
   @State private var nflPlayer: NFLRosterModel.NFLPlayer?

   var body: some View {
	  ZStack(alignment: .topLeading) {
		 // Background gradient
		 RoundedRectangle(cornerRadius: 15)
			.fill(LinearGradient(
			   gradient: Gradient(colors: [teamColor, .clear]),
			   startPoint: .top,
			   endPoint: .bottom
			))
			.frame(height: 95)
			.overlay(
			   RoundedRectangle(cornerRadius: 15)
				  .stroke(Color.gray, lineWidth: 1) // Add 1px gray stroke
			)

		 // Team Logo
		 if let teamLogoURL = getTeamLogoURL() {
			AsyncImage(url: teamLogoURL) { phase in
			   switch phase {
				  case .empty:
					 ProgressView()
				  case .success(let image):
					 image
						.resizable()
						.aspectRatio(contentMode: .fit)
				  case .failure:
					 Image(systemName: "sportscourt.fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
				  @unknown default:
					 EmptyView()
			   }
			}
			.frame(width: 80, height: 80)
			.offset(x: 20, y: -4) // Adjusted offset
			.zIndex(0) // Set z-index to be behind player image
			.opacity(0.6) // Add opacity to the team logo
						  // Add glow effect
			.shadow(color: teamColor.opacity(0.5), radius: 10, x: 0, y: 0)
		 }

		 // MARK: Jersey number #
		 VStack {
			HStack {
			   Spacer() // Push the ZStack to the trailing edge
			   ZStack(alignment: .topTrailing) {
				  // APPLY: Separate jersey number and '#' symbol
				  Text(nflPlayer?.jersey ?? "")
					 .font(.system(size: 85, weight: .bold))
					 .italic()
					 .foregroundColor(teamColor.adjustBrightness(by: 0.5))
					 .opacity(0.35)
			   }
			}
			.padding(.trailing, 8)
			Spacer()
		 }
		 .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
		 .zIndex(1)

		 HStack(spacing: 12) {
			// Player Image
			AsyncImage(url: getPlayerImageURL()) { phase in
			   switch phase {
				  case .empty:
					 ProgressView()
				  case .success(let image):
					 image
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: 95, height: 95)
						.clipped()
				  case .failure:
					 Image(systemName: "person.fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 95, height: 95)
				  @unknown default:
					 EmptyView()
			   }
			}
//			.clipShape(RoundedRectangle(cornerRadius: 15))
			.offset(x: -20, y: -5)
			.zIndex(2)

			VStack(alignment: .trailing, spacing: 0) {
			   Text(getPositionString())
				  .font(.system(size: 15))
				  .foregroundColor(.white.opacity(0.8))
				  .offset(x: -5, y: 42)

			   Spacer()

			   HStack(alignment: .bottom, spacing: 4) {
				  Spacer()
				  Text(String(format: "%.2f", getPlayerScore()))
					 .font(.system(size: 22, weight: .bold))
					 .foregroundColor(.white)
					 .lineLimit(1)
					 .minimumScaleFactor(0.95)
					 .scaledToFit()
			   }
			   .frame(maxWidth: .infinity, alignment: .trailing)
			   .offset(y: -9)
			}
			.padding(.vertical, 8)
			.padding(.trailing, 8)
			.zIndex(3)
		 }

		 // APPLY: Add an overlay for the player's full name
		 Text(player.playerPoolEntry.player.fullName)
			.font(.system(size: 18, weight: .bold))
			.foregroundColor(.white)
			.lineLimit(2)
			.minimumScaleFactor(0.9)
			.frame(maxWidth: .infinity, alignment: .trailing)
			.padding(.top, 6)
			.padding(.trailing, 14)
			.padding(.leading, 45) // Add some padding to avoid overlapping with the player image
//			.background(Color.black.opacity(0.2)) // Add a semi-transparent background
			.zIndex(4) // Ensure it's on top of other elements
	  }
	  .frame(height: 95)
	  .cornerRadius(15)
	  .shadow(radius: 5)
	  .onAppear {
		 self.nflPlayer = NFLRosterModel.getPlayerInfo(by: player.playerPoolEntry.player.fullName, from: fantasyViewModel.nflRosterViewModel.players)
		 teamColor = Color(hex: nflPlayer?.team?.color ?? "008C96")
	  }
   }

   func getPlayerImageURL() -> URL? {
	  let playerId = String(player.playerPoolEntry.player.id)
	  if fantasyViewModel.leagueID == AppConstants.ESPNLeagueID[1] {
		 return URL(string: "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/\(playerId).png&w=200&h=145")
	  } else {
		 return URL(string: "https://sleepercdn.com/content/nfl/players/thumb/\(playerId).jpg")
	  }
   }

   func getTeamLogoURL() -> URL? {
	  return URL(string: nflPlayer?.team?.logo ?? "")
   }

   func getPlayerScore() -> Double {
	  if fantasyViewModel.leagueID == AppConstants.ESPNLeagueID[1] {
		 return fantasyViewModel.getPlayerScore(for: player, week: fantasyViewModel.selectedWeek)
	  } else {
		 // For Sleeper, use the calculateSleeperPlayerScore function
		 return fantasyViewModel.calculateSleeperPlayerScore(playerId: String(player.playerPoolEntry.player.id))
	  }
   }

   func getPositionString() -> String {
	  return fantasyViewModel.positionString(player.lineupSlotId)
   }
}
