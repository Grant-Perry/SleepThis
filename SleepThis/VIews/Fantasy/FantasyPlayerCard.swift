// #fuc
// This version corrects the conditional logic for the stroke and shadow to properly show green
// when the game is live and gray when not. It also ensures that each card calls configure on appear,
// which will fetch or retrieve cached scoreboard data from FantasyScoreboardModel. As a result,
// all player cards will load matchup information once the scoreboard data is available.
//
// Note: Since the scoreboard data is fetched asynchronously and cached, the first time you load the
// view it may take a moment for the data to come in. After that, subsequent navigations will have
// immediate data from cache. Each card has its own instance of FantasyGameMatchupViewModel, which
// is @StateObject, meaning it will persist as long as the card is in view, updating when the scoreboard
// data becomes available.

import SwiftUI

struct FantasyPlayerCard: View {
   let player: FantasyScores.FantasyModel.Team.PlayerEntry
   let fantasyViewModel: FantasyMatchupViewModel
   @State private var teamColor: Color = .gray
   @State private var nflPlayer: NFLRosterModel.NFLPlayer?

   @StateObject private var fantasyGameMatchupViewModel = FantasyGameMatchupViewModel()

   var body: some View {
	  ZStack(alignment: .topLeading) {
		 // Background with gradient and conditional stroke/shadow if game is live
		 RoundedRectangle(cornerRadius: 15)
			.fill(LinearGradient(
			   gradient: Gradient(colors: [teamColor, .clear]),
			   startPoint: .top,
			   endPoint: .bottom
			))
			.frame(height: 95)
			.overlay(
			   RoundedRectangle(cornerRadius: 15)
				  .stroke(fantasyGameMatchupViewModel.liveMatchup ? Color.gpGreen : Color.gray,
						  lineWidth: fantasyGameMatchupViewModel.liveMatchup ? 5 : 1)
			)
			.shadow(color: fantasyGameMatchupViewModel.liveMatchup ? .gpGreen : .clear,
					radius: 10, x: 10, y: 10)

		 // Team logo
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
			.opacity(0.6)
			.shadow(color: teamColor.opacity(0.5), radius: 10, x: 0, y: 0)
		 }

		 // Jersey number
		 VStack {
			HStack {
			   Spacer()
			   ZStack(alignment: .topTrailing) {
				  Text(nflPlayer?.jersey ?? "")
					 .font(.system(size: 85, weight: .bold))
					 .italic()
					 .foregroundColor(.white.opacity(0.25))
//					 .foregroundColor(teamColor.opacity(0.5))
			   }
			}
			.padding(.trailing, 8)
			Spacer()
		 }
		 .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

		 HStack(spacing: 12) {
			// Player image
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

			VStack(alignment: .trailing, spacing: 0) {
			   Text(getPositionString())
				  .font(.system(size: 12))
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
		 }

		 // Player name
		 Text(player.playerPoolEntry.player.fullName)
			.font(.system(size: 18, weight: .bold))
			.foregroundColor(.white)
			.lineLimit(2)
			.minimumScaleFactor(0.9)
			.frame(maxWidth: .infinity, alignment: .trailing)
			.padding(.top, 6)
			.padding(.trailing, 14)
			.padding(.leading, 45)

		 // Game matchup info (top-right, at bottom of card)
		 VStack {
			Spacer()
			HStack {
			   Spacer()
			   FantasyGameMatchupView(gameMatchupViewModel: fantasyGameMatchupViewModel)
				  .padding(.trailing, 20)
				  .padding(.bottom, 6)
			}
		 }
	  }
	  .frame(height: 95)
	  .cornerRadius(15)
	  .shadow(radius: 5)
	  .onAppear {
		 self.nflPlayer = NFLRosterModel.getPlayerInfo(by: player.playerPoolEntry.player.fullName, from: fantasyViewModel.nflRosterViewModel.players)
		 teamColor = Color(hex: nflPlayer?.team?.color ?? "008C96")

		 // Configure the matchup view model with the team's abbreviation and the current refresh interval
		 if let teamAbbrev = nflPlayer?.team?.abbreviation {
			let interval = UserDefaults.standard.integer(forKey: "autoRefreshInterval")
			fantasyGameMatchupViewModel.configure(teamAbbreviation: teamAbbrev, refreshInterval: interval)
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
	  if fantasyViewModel.leagueID == AppConstants.ESPNLeagueID[1] {
		 return fantasyViewModel.getPlayerScore(for: player, week: fantasyViewModel.selectedWeek)
	  } else {
		 return fantasyViewModel.calculateSleeperPlayerScore(playerId: String(player.playerPoolEntry.player.id))
	  }
   }

   func getPositionString() -> String {
	  return fantasyViewModel.positionString(player.lineupSlotId)
   }
}
