import SwiftUI

struct LivePlayerDetailView: View {
   var player: Player
   @StateObject private var nflRosterViewModel = NFLRosterViewModel()
   @State private var nflPlayer: NFLRosterModel.NFLPlayer?

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
			   .frame(height: 180)

			HStack(alignment: .center) {
			   // Player Image
			   LivePlayerImageView(playerID: player.id)

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
			   .padding(.trailing, -22)
			}

			// Jersey Number Overlay
			VStack {
			   ZStack(alignment: .topLeading) {
				  Text(nflPlayer?.jersey ?? "")
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
			   Text("\(positionName(for: player.defaultPositionID ?? 0))")
				  .font(.headline)
				  .foregroundColor(.white)
				  .bold()
				  .padding(.leading, 110)
				  .padding(.bottom, 60)
			   Spacer()
			}
			.opacity(0.5)
			.offset(y: -25)
		 }
		 .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 200)
		 .padding(.vertical, 4)
		 .padding(.horizontal, 4)
		 .clipped()
		 .cornerRadius(25.0)

		 // ScrollView for the Player Info Grid and Stats
		 ScrollView {
			// Player information grid
			LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
			   LivePlayerInfoRowView(label: "Height", value: nflPlayer?.displayHeight)
			   LivePlayerInfoRowView(label: "Weight", value: nflPlayer?.displayWeight)
			   LivePlayerInfoRowView(label: "Age", value: nflPlayer?.age?.description)
			   LivePlayerInfoRowView(label: "Team", value: nflPlayer?.team?.displayName)
			   LivePlayerInfoRowView(label: "Position", value: nflPlayer?.position?.displayName)
			   LivePlayerInfoRowView(label: "Jersey", value: nflPlayer?.jersey)
			}
			.padding()
			.background(RoundedRectangle(cornerRadius: 15)
			   .fill(Color.black.opacity(0.2)))
			.padding(.horizontal, 16)
			.offset(y: -25)

			// Player Stats Grid
			LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
			   if let stats = player.stats {
				  ForEach(stats.indices, id: \.self) { index in
					 let stat = stats[index]
					 if let appliedStats = stat.appliedStats {
						ForEach(appliedStats.keys.sorted(), id: \.self) { key in
						   LivePlayerInfoRowView(label: statName(for: key), value: "\(appliedStats[key] ?? 0)")
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
	  .onAppear {
		 fetchNFLPlayerInfo()
	  }
	  .preferredColorScheme(.dark)
   }

   private func fetchNFLPlayerInfo() {
	  // Try to look up the NFL player info using the NFLRosterViewModel
	  nflPlayer = nflRosterViewModel.players.first { $0.fullName.lowercased() == player.fullName?.lowercased() }
   }

   func positionName(for positionID: Int) -> String {
	  switch positionID {
		 case 1: return "Quarterback"
		 case 2: return "Running Back"
		 case 3: return "Wide Receiver"
		 case 4: return "Tight End"
		 case 5: return "Kicker"
		 case 16: return "Defense/Special Teams"
		 default: return "Unknown"
	  }
   }

   // Helper function to return the stat's name based on its ID
   func statName(for statID: String) -> String {
	  switch statID {
		 case "0": return "Pass Attempts"
		 case "1": return "Pass Completions"
		 case "3": return "Pass Yards"
		 case "4": return "Pass Touchdowns"
		 case "23": return "Rush Attempts"
		 case "24": return "Rush Yards"
		 case "25": return "Rush Touchdowns"
		 case "41": return "Receptions"
		 case "42": return "Receiving Yards"
		 case "43": return "Receiving Touchdowns"
		 case "53": return "Total Points"
		 case "58": return "Targets"
		 default: return "Stat \(statID)"
	  }
   }
}
