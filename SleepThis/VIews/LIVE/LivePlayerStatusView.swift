import SwiftUI

struct LivePlayerStatsView: View {
   let stats: [PlayerStat]

   var body: some View {
	  VStack(alignment: .leading, spacing: 10) {
		 Text("Player Stats")
			.font(.headline)
			.padding(.bottom, 10)

		 // Iterate through the player's stats
		 ForEach(stats.indices, id: \.self) { index in
			let stat = stats[index]

			if let appliedStats = stat.appliedStats {
			   ForEach(appliedStats.keys.sorted(), id: \.self) { key in
				  HStack {
					 Text(statName(for: key))
						.font(.subheadline)
						.foregroundColor(.gray)

					 Spacer()

					 Text("\(appliedStats[key] ?? 0)")
						.font(.subheadline)
						.foregroundColor(.white)
				  }
				  .padding(.horizontal, 10)
				  .padding(.vertical, 4)
				  .background(
					 RoundedRectangle(cornerRadius: 10)
						.fill(Color.black.opacity(0.2))
				  )
			   }
			}
		 }
	  }
	  .padding()
	  .background(RoundedRectangle(cornerRadius: 15)
		 .fill(Color.black.opacity(0.5)))
	  .padding(.top, 10)
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

