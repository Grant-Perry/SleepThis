import SwiftUI

struct FantasyPlayerCard: View {
   let player: FantasyScores.FantasyModel.Team.PlayerEntry
   let fantasyViewModel: FantasyMatchupViewModel
   
   @State private var teamColor: Color = .gray
   @State private var nflPlayer: NFLRosterModel.NFLPlayer?
   @StateObject private var fantasyGameMatchupViewModel = FantasyGameMatchupViewModel()
   var isActive: Bool = true
   
   var body: some View {
	  VStack {
		 ZStack(alignment: .topLeading) {
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
			
			RoundedRectangle(cornerRadius: 15)
			   .fill(
				  LinearGradient(
					 gradient: Gradient(colors: [teamColor, .clear]),
					 startPoint: .top,
					 endPoint: .bottom
				  )
			   )
			
			if let teamLogoURL = fantasyViewModel.getTeamLogoURL(for: player) {
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
			
			HStack(spacing: 12) {
			   AsyncImage(url: fantasyViewModel.getPlayerImageURL(for: player)) { phase in
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
			   .zIndex(2)
			   
			   VStack(alignment: .trailing, spacing: 0) {
				  Text(fantasyViewModel.getPositionString(for: player))
					 .font(.system(size: 15))
					 .foregroundColor(.white.opacity(0.8))
					 .offset(x: -5, y: 45)
				  
				  Spacer()
				  
				  HStack(alignment: .bottom, spacing: 4) {
					 Spacer()
					 Text(String(format: "%.2f", fantasyViewModel.getPlayerScore(for: player)))
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
			
			Text(player.playerPoolEntry.player.fullName)
			   .font(.system(size: 18, weight: .bold))
			   .foregroundColor(.white)
			   .lineLimit(1)
			   .minimumScaleFactor(0.9)
			   .frame(maxWidth: .infinity, alignment: .trailing)
			   .padding(.top, 16)
			   .padding(.trailing, 14)
			   .padding(.leading, 45)
			   .zIndex(4)
			
			VStack {
			   Spacer()
			   HStack {
				  Spacer()
				  FantasyGameMatchupView(gameMatchupViewModel: fantasyGameMatchupViewModel)
					 .padding(EdgeInsets(top: 8, leading: 0, bottom: 22, trailing: 42))
			   }
			}
			.offset(x: -12, y: -2)
			.zIndex(5)
		 }
		 .frame(height: 90)
		 
		 .background(
			RoundedRectangle(cornerRadius: 15)
			   .fill(Color.black)
			   .shadow(color: isActive ? .gpGreen.opacity(0.5) : .clear, radius: 10)
		 )
		 .overlay(
			RoundedRectangle(cornerRadius: 15)
			   .stroke(Color.gray, lineWidth: 1)
		 )
		 .clipShape(RoundedRectangle(cornerRadius: 15))
		 
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
	  // if liveMatchup, put a green glow and border around the card
	  .shadow(color: fantasyGameMatchupViewModel.liveMatchup ? .gpGreen : .clear, radius: 7, x: 0, y: 0)
   }
}
