import SwiftUI

struct PlayerDetailView: View {
   let player: PlayerModel
   let playerViewModel: PlayerViewModel
   @StateObject var nflRosterViewModel: NFLRosterViewModel // Add this property to access the NFL roster
   var playerSize = 350.0
   let round: Int? // Add optional round parameter
   let pickNo: Int? // Add optional pickNo parameter
   @State private var isExpanded: Bool = false
   @State private var nflPlayer: NFLRosterModel.NFLPlayer?

   var body: some View {
	  let teamColor = Color(hex: nflPlayer?.team?.color ?? "008C96")
	  let teamLogoURL = URL(string: nflPlayer?.team?.logo ?? "")

	  VStack {
		 // Top Background Section with Player Image and Team Logo
		 ZStack(alignment: .bottomLeading) {
			RoundedRectangle(cornerRadius: 15)
			   .fill(LinearGradient(
				  gradient: Gradient(colors: [teamColor, .clear]),
				  startPoint: .top,
				  endPoint: .bottom
			   ))
			   .shadow(radius: 4)
			   .frame(height: 180)

			// Player and Team logo
			ZStack(alignment: .center) {
			   // Team Logo
			   if let teamLogoURL = teamLogoURL {
				  AsyncImage(url: teamLogoURL) { phase in
					 switch phase {
						case .empty:
						   Image(systemName: "photo")
							  .resizable()
							  .frame(width: 180, height: 180)
							  .opacity(0.5)
						case .success(let image):
						   image
							  .resizable()
							  .frame(width: 180, height: 180)
							  .offset(x: -15, y: 18)
							  .opacity(0.5)
							  .clipped()
						case .failure:
						   Image(systemName: "photo")
							  .resizable()
							  .frame(width: 180, height: 180)
							  .opacity(0.35)
						@unknown default:
						   EmptyView()
					 }
				  }
				  .padding(.bottom, -40)
				  .padding(.trailing, -42)
			   }

			   // Player Image
			   if let playerImageURL = URL(string: "https://sleepercdn.com/content/nfl/players/\(player.id).jpg") {
				  AsyncImage(url: playerImageURL) { phase in
					 switch phase {
						case .empty:
						   Image(systemName: "person.crop.circle.fill")
							  .resizable()
							  .frame(width: 180, height: 180)
						case .success(let image):
						   image
							  .resizable()
							  .scaledToFill()
							  .frame(width: 180, height: 180)
							  .offset(x: -50)
							  .isOnIR(player.injuryStatus ?? "", hXw: 180)
						case .failure:
						   Image(systemName: "person.crop.circle.fill")
							  .resizable()
							  .frame(width: 180, height: 180)
						@unknown default:
						   EmptyView()
					 }
				  }
			   }
			   Spacer()
			}
			.padding()

			// Jersey Number Overlay
			VStack {
			   ZStack(alignment: .topLeading) {
				  // Jersey number
				  Text(player.number.map { "\($0)" } ?? "N/A")
					 .font(.system(size: 115, weight: .bold))
					 .italic()
					 .foregroundColor(teamColor.adjustBrightness(by: 0.5))
					 .opacity(0.35)

				  // # symbol, positioned at the top leading corner
				  Text("#")
					 .font(.system(size: 55, weight: .light))
					 .foregroundColor(teamColor.adjustBrightness(by: 0.25))
					 .offset(x: -10, y: 10)
			   }
			   .offset(x: 0, y: -70)
			}
			.frame(maxWidth: .infinity, alignment: .topTrailing)

			// Player Name Overlay on Top
			VStack {
			   Text(player.fullName ?? "Unknown Player")
				  .font(.system(size: 48))
				  .foregroundColor(teamColor.blended(withFraction: 0.55, of: .white))
				  .bold()
				  .lineLimit(1)
				  .minimumScaleFactor(0.5)
				  .padding(.trailing, 20)
				  .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
			}
			.offset(x: 100, y: -100)

			// Position and Status
			HStack {
			   Text("\(player.position ?? "N/A")\(player.depthChartOrder ?? 0)")
				  .font(.headline)
				  .foregroundColor(.white)
				  .bold()
				  .padding(.leading, 110)
				  .padding(.bottom, 60)
			   Spacer()
			}
			.opacity(0.65)
			.offset(y: -25)

			HStack {
			   Text("Status: \(player.status ?? "N/A")")
				  .font(.headline)
				  .foregroundColor(.white)
				  .bold()
				  .padding(.leading, 220)
				  .padding(.bottom, 60)
			   Spacer()
			}
			.opacity(0.5)
			.offset(y: -25)

			// Player Information Chevron in the header box
			HStack {
			   Spacer()
			   Button(action: {
				  withAnimation {
					 isExpanded.toggle()
				  }
			   }) {
				  Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
					 .foregroundColor(.white)
					 .font(.headline)
			   }
			}
			.padding(.trailing, 140)
			.padding(.bottom, 20)
		 }
		 .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 200)
		 .padding(.vertical, 4)
		 .padding(.horizontal, 4)
		 .clipped()
		 .cornerRadius(25.0)

		 // Player Info Section with Disclosure Group
		 if isExpanded {
			LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
			   PlayerInfoRowView(label: "Height", value: player.height, nflPlayer: nflPlayer)
			   PlayerInfoRowView(label: "Weight", value: player.weight, nflPlayer: nflPlayer)
			   PlayerInfoRowView(label: "Age", value: player.age?.description, nflPlayer: nflPlayer)
			   PlayerInfoRowView(label: "ID", value: player.id, nflPlayer: nflPlayer)
			   PlayerInfoRowView(label: "Team", value: player.team, nflPlayer: nflPlayer)
			   PlayerInfoRowView(label: "Position", value: player.position, nflPlayer: nflPlayer)
			   PlayerInfoRowView(label: "Status", value: player.status, nflPlayer: nflPlayer)
			   PlayerInfoRowView(label: "College", value: player.college, nflPlayer: nflPlayer)
			   PlayerInfoRowView(label: "Birth Country", value: player.birthCountry, nflPlayer: nflPlayer)
			   PlayerInfoRowView(label: "Years Experience", value: player.yearsExp?.description, nflPlayer: nflPlayer)
			   PlayerInfoRowView(label: "Number", value: player.number?.description, nflPlayer: nflPlayer)
			   PlayerInfoRowView(label: "Depth Chart Position", value: player.depthChartPosition?.description, nflPlayer: nflPlayer)
			   PlayerInfoRowView(label: "Depth Chart Order", value: player.depthChartOrder?.description, nflPlayer: nflPlayer)
			   PlayerInfoRowView(label: "Drafted", value: "Round \(round ?? 0), Pick \(pickNo ?? 0)", nflPlayer: nflPlayer)
			}
			.padding()
			.background(RoundedRectangle(cornerRadius: 15)
			   .fill(Color(teamColor).opacity(0.2)))
			.padding(.horizontal, 16)
			.offset(y: -25)
		 }

		 Spacer()
	  }
	  .preferredColorScheme(.dark)
	  .onAppear {
		 if nflRosterViewModel.players.isEmpty {
			print("[onAppear:] NFL roster is empty, fetching players...")
			nflRosterViewModel.fetchPlayersForAllTeams {
			   print("[onAppear:] NFL roster loaded with \(nflRosterViewModel.players.count) players.")
			   self.nflPlayer = NFLRosterModel.getPlayerInfo(by: player.fullName ?? "", from: nflRosterViewModel.players)
			   if let nflPlayer = nflPlayer {
				  print("[onAppear:] Loaded NFLPlayer info for \(nflPlayer.fullName).")
			   } else {
				  print("[onAppear:] Player not found in NFL roster.")
			   }
			}
		 } else {
			print("[onAppear:] NFL roster already loaded with \(nflRosterViewModel.players.count) players.")
			self.nflPlayer = NFLRosterModel.getPlayerInfo(by: player.fullName ?? "", from: nflRosterViewModel.players)
			if let nflPlayer = nflPlayer {
			   print("[onAppear:] Loaded NFLPlayer info for \(nflPlayer.fullName).")
			} else {
			   print("[onAppear:] Player not found in NFL roster.")
			}
		 }
	  }
   }

   @ViewBuilder
   private func PlayerInfoRowView(label: String, value: String?, nflPlayer: NFLRosterModel.NFLPlayer?) -> some View {
	  if let value = value, !value.isEmpty {
		 VStack(alignment: .leading, spacing: 4) {
			Text("\(label):")
			   .font(.headline)
			   .foregroundColor(Color(hex: nflPlayer?.team?.color ?? "008C96"))
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
			   .scaledToFit()

			Text(value)
			   .font(.subheadline)
			   .fontWeight(.bold)
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
			   .scaledToFit()
			   .foregroundColor(.white)
		 }
		 .padding(.vertical, 4)
	  }
   }
}
