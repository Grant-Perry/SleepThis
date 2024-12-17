import SwiftUI

struct FantasyPlayerCard: View {
   let player: FantasyScores.FantasyModel.Team.PlayerEntry
   let fantasyViewModel: FantasyMatchupViewModel

   @State private var teamColor: Color = .gray
   @State private var nflPlayer: NFLRosterModel.NFLPlayer?
   @StateObject private var fantasyGameMatchupViewModel = FantasyGameMatchupViewModel()

   var body: some View {
	  ZStack(alignment: .topLeading) {
		 // 1. Jersey Number Layer First (Behind Everything)
		 VStack {
			HStack {
			   Spacer()
			   ZStack(alignment: .topTrailing) {
				  Text(nflPlayer?.jersey ?? "")
					 .font(.system(size: 85, weight: .bold))
					 .italic()
					 .foregroundColor(teamColor)
					 .opacity(0.7)
			   }
			}
			.padding(.trailing, 8)
			Spacer()
		 }
		 .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

		 // 2. Background Gradient & Border
		 RoundedRectangle(cornerRadius: 15)
			.fill(
			   LinearGradient(
				  gradient: Gradient(colors: [teamColor, .clear]),
				  startPoint: .top,
				  endPoint: .bottom
			   )
			)
			.frame(height: 95)
			.overlay(
			   RoundedRectangle(cornerRadius: 15)
				  .stroke(
					 fantasyGameMatchupViewModel.liveMatchup ? Color.gpGreen : Color.gray,
					 lineWidth: fantasyGameMatchupViewModel.liveMatchup ? 5 : 1
				  )
			)
			.shadow(
			   color: fantasyGameMatchupViewModel.liveMatchup ? .gpGreen : .clear,
			   radius: 10, x: 0, y: 0
			)

		 // 3. Team Logo
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
			.offset(x: 20, y: -4)
			.zIndex(0)
			.opacity(0.6)
			.shadow(color: teamColor.opacity(0.5), radius: 10, x: 0, y: 0)
		 }

		 // 4. Player Image & Stats
		 HStack(spacing: 12) {
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
			.offset(x: -20, y: -5)
			.zIndex(2) // Player image above jersey number but under text

			VStack(alignment: .trailing, spacing: 0) {
			   // Position text in front of jersey number
			   Text(getPositionString())
				  .font(.system(size: 15))
				  .foregroundColor(.white.opacity(0.8))
				  .offset(x: -5, y: 45)

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
			.zIndex(3) // Score and position above jersey number
		 }

		 // 5. Player Name
		 Text(player.playerPoolEntry.player.fullName)
			.font(.system(size: 18, weight: .bold))
			.foregroundColor(.white)
			.lineLimit(2)
			.minimumScaleFactor(0.9)
			.frame(maxWidth: .infinity, alignment: .trailing)
			.padding(.top, 10) // More padding at top as requested
			.padding(.trailing, 14)
			.padding(.leading, 45)
			.zIndex(4) // Player name above jersey number

		 // 6. FantasyGameMatchupView
		 VStack {
			Spacer()
			HStack {
			   Spacer()
			   FantasyGameMatchupView(gameMatchupViewModel: fantasyGameMatchupViewModel)
				  .padding(EdgeInsets(top: 8, leading: 0, bottom: 22, trailing: 42))
			}
		 }
		 .offset(y: 6)
		 .zIndex(5)
	  }
	  .frame(height: 95)
	  .cornerRadius(15)
	  .shadow(radius: 5)

	  .task {
		 self.nflPlayer = NFLRosterModel.getPlayerInfo(
			by: player.playerPoolEntry.player.fullName,
			from: fantasyViewModel.nflRosterViewModel.players
		 )
		 teamColor = Color(hex: nflPlayer?.team?.color ?? "008C96")

		 if let teamAbbrev = nflPlayer?.team?.abbreviation {
			let interval = UserDefaults.standard.integer(forKey: "autoRefreshInterval")
			let week = fantasyViewModel.selectedWeek
			let year = fantasyViewModel.selectedYear
			fantasyGameMatchupViewModel.configure(
			   teamAbbreviation: teamAbbrev,
			   week: week,
			   year: year,
			   refreshInterval: interval
			)
		 }
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
	  let week = fantasyViewModel.selectedWeek
	  if fantasyViewModel.leagueID == AppConstants.ESPNLeagueID[1] {
		 return fantasyViewModel.getPlayerScore(for: player, week: week)
	  } else {
		 return fantasyViewModel.calculateSleeperPlayerScore(playerId: String(player.playerPoolEntry.player.id))
	  }
   }

   func getPositionString() -> String {
	  return fantasyViewModel.positionString(player.lineupSlotId)
   }
}
