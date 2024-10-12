import SwiftUI

struct LivePlayerDetailView: View {
   var player: Player

   var body: some View {
	  ScrollView {
		 VStack(alignment: .leading) {
			// Player image
			PlayerImageView(playerID: player.id)

			// Player details
			PlayerInfoView(player: player)

			// Player stats
			if let stats = player.stats, !stats.isEmpty {
			   PlayerStatsView(stats: stats)
			} else {
			   Text("No stats available")
				  .padding(.top, 10)
			}

			Spacer()
		 }
		 .padding()
		 .navigationTitle(player.fullName ?? "Player Details")
	  }
   }
}

// Subview for player image
struct PlayerImageView: View {
   let playerID: Int?

   var body: some View {
	  let playerID = playerID ?? 0
	  let imageUrl = URL(string: "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/\(playerID).png&w=120&h=120")

	  AsyncImage(url: imageUrl) { image in
		 image
			.resizable()
			.frame(width: 120, height: 120)
			.clipShape(Circle())
	  } placeholder: {
		 ProgressView()
			.frame(width: 120, height: 120)
	  }
   }
}

// Subview for player information
struct PlayerInfoView: View {
   let player: Player

   var body: some View {
	  VStack(alignment: .leading) {
		 Text(player.fullName ?? "Unknown Player")
			.font(.title)
			.padding(.top)

		 Text("Position: \(positionName(for: player.defaultPositionID ?? 0))")
			.padding(.top, 5)

		 if let proTeamID = player.proTeamId {
			Text("Team ID: \(proTeamID)")
			   .padding(.top, 5)
		 }
	  }
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
}

// Subview for player stats
struct PlayerStatsView: View {
   let stats: [PlayerStat]

   var body: some View {
	  VStack(alignment: .leading) {
		 Text("Player Stats:")
			.font(.headline)
			.padding(.top, 10)

		 ForEach(stats.indices, id: \.self) { index in
			let stat = stats[index]
			if let appliedStats = stat.appliedStats {
			   ForEach(appliedStats.keys.sorted(), id: \.self) { key in
				  Text("\(statName(for: key)): \(appliedStats[key] ?? 0)")
					 .padding(.leading)
			   }
			}
		 }
	  }
   }

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
