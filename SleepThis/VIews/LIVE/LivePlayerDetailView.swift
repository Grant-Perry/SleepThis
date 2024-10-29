import SwiftUI

struct LivePlayerDetailView: View {
   var player: Player
   @StateObject private var nflRosterViewModel = NFLRosterViewModel()
   @State private var nflPlayer: NFLRosterModel.NFLPlayer?
   var picSize: CGFloat = 180

   var body: some View {
	  VStack {
		 // Header section with player image, team logo, and basic details
		 ZStack(alignment: .bottomTrailing) {
			let teamColor = Color(hex: nflPlayer?.team?.color ?? "4b92db")

			RoundedRectangle(cornerRadius: 15)
			   .fill(LinearGradient(
				  gradient: Gradient(colors: [teamColor, .clear]),
				  startPoint: .top,
				  endPoint: .bottom
			   ))
			   .shadow(radius: 4)
			   .frame(height: picSize)

			HStack(alignment: .center) {
			   // Player Image
			   LivePlayerImageView(playerID: player.id, picSize: 50)

			   Spacer() // Push content to the right
			}
			.padding()

			// Team Logo
			if let teamLogoURL = URL(string: nflPlayer?.team?.logo ?? "") {
			   AsyncImage(url: teamLogoURL) { phase in
				  switch phase {
					 case .empty:
						Image(systemName: "photo")
						   .resizable()
						   .frame(width: picSize, height: picSize)
						   .opacity(0.5)
					 case .success(let image):
						image
						   .resizable()
						   .frame(width: picSize, height: picSize)
						   .offset(x: -15, y: 18)
						   .opacity(0.5)
						   .clipped()
					 case .failure:
						Image(systemName: "photo")
						   .resizable()
						   .frame(width: picSize, height: picSize)
						   .opacity(0.35)
					 @unknown default:
						EmptyView()
				  }
			   }
			   .padding(.bottom, -40)
			   .padding(.trailing, -22)
			}

			// Jersey Number Overlay
			VStack {
			   ZStack(alignment: .topLeading) {
				  Text(nflPlayer?.jersey ?? "00")
					 .font(.system(size: 115, weight: .bold))
					 .italic()
					 .foregroundColor(teamColor.adjustBrightness(by: 0.5))
					 .opacity(0.35)

				  Text("#")
					 .font(.system(size: 55, weight: .light))
					 .foregroundColor(teamColor.adjustBrightness(by: 0.25))
					 .offset(x: -10, y: 10)
			   }
			   .offset(x: 0, y: -70)
			}

			// Player Name Overlay
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
			.offset(x: 10, y: -100)

			// Position
			HStack {
			   Text("\(nflPlayer?.position?.abbreviation ?? "")")
				  .font(.headline)
				  .foregroundColor(.white)
				  .bold()
				  .padding(.leading, 110)
				  .padding(.bottom, 60)

			   Spacer()
			}
			.opacity(0.5)
			.offset(x: 40, y: -25)
		 }
		 .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 200)
		 .padding(.vertical, 4)
		 .padding(.horizontal, 4)
		 .clipped()
		 .cornerRadius(25.0)

		 // ScrollView for the Player Info Grid and Stats
		 ScrollView {
			VStack {
			   // Player information grid
//			   LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
//				  LivePlayerInfoRowView(label: "Height", value: nflPlayer?.displayHeight?.description)
//				  LivePlayerInfoRowView(label: "Weight", value: nflPlayer?.displayWeight?.description)
//				  LivePlayerInfoRowView(label: "Age", value: nflPlayer?.age?.description)
//				  LivePlayerInfoRowView(label: "Team", value: nflPlayer?.team?.displayName.description)
//				  LivePlayerInfoRowView(label: "Position", value: nflPlayer?.position?.displayName.description)
//				  LivePlayerInfoRowView(label: "Jersey", value: nflPlayer?.jersey)
//			   }
//			   .padding()
//			   .background(RoundedRectangle(cornerRadius: 15)
//				  .fill(Color.black.opacity(0.2)))
//			   .padding(.horizontal, 16)
//			   .offset(y: -25)

			   // Player Stats Grid
			   LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
				  if let stats = player.stats {
					 ForEach(stats.indices, id: \.self) { index in
						let stat = stats[index]
						if let appliedStats = stat.appliedStats {
						   ForEach(appliedStats.keys.sorted(), id: \.self) { key in
							  LivePlayerInfoRowView(label: StatType(rawValue: key)?.description ?? "[UK]", value: "\(appliedStats[key] ?? 0)")
						   }
						}
					 }
				  }
			   }
			   .padding()
			   .background(RoundedRectangle(cornerRadius: 15)
				  .fill(Color.black.opacity(0.5)))
			   .padding(.top, 10)
			}
		 }
	  }
	  .onAppear {
		 if nflRosterViewModel.players.isEmpty {
			nflRosterViewModel.fetchPlayersForAllTeams {
			   print("[onAppear:] Loaded \(nflRosterViewModel.players.count) players.")
			   fetchNFLPlayerInfo()
			}
		 } else {
			print("[onAppear:] NFL roster already contains \(nflRosterViewModel.players.count) players.")
			fetchNFLPlayerInfo()
		 }
	  }
	  .preferredColorScheme(.dark)
   }

   private func fetchNFLPlayerInfo() {
	  // Normalize the player name for comparison
	  guard let fullName = player.fullName?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else {
		 print("Player full name is missing or invalid.")
		 return
	  }

	  // Try to look up the NFL player info using the NFLRosterViewModel
	  nflPlayer = nflRosterViewModel.players.first { $0.fullName.lowercased() == fullName }

	  if let nflPlayer = nflPlayer {
		 print("Player Team: \(nflPlayer.team?.displayName ?? "No team")")
		 print("Team Color: \(nflPlayer.team?.color ?? "No color")")
		 print("Player Jersey: \(nflPlayer.jersey ?? "No jersey")")
	  }
   }

   func positionName(for positionID: String) -> String {
	  switch positionID {
		 case "Quarter Back": return "QB"
		 case "Running Back": return "RB"
		 case "Wide Receiver": return "WR"
		 case "Tight End": return "TE"
		 case "Kicker": return "K"
		 case "Defense": return "D/ST"
		 default: return "?"
	  }
   }
}
