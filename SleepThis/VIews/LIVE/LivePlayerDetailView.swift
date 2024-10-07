import SwiftUI

struct LivePlayerDetailView: View {
   let player: LivePlayerModel

   var body: some View {
	  ScrollView {
		 VStack(alignment: .leading, spacing: 10) {
			Text(player.playerPoolEntry.player.fullName)
			   .font(.title)
			   .fontWeight(.bold)

			playerInfoSection

			statsSection

			if !player.playerPoolEntry.player.stats.isEmpty {
			   latestGameStatsSection
			}
		 }
		 .padding()
	  }
	  .navigationTitle("Player Details")
   }

   private var playerInfoSection: some View {
	  VStack(alignment: .leading, spacing: 5) {
		 Text("Position: \(Position(rawValue: player.playerPoolEntry.player.defaultPositionId)?.name ?? "Unknown")")
		 Text("Lineup Slot: \(LineupSlot(rawValue: player.lineupSlotId)?.name ?? "Unknown")")
		 Text("Status: \(player.playerPoolEntry.status ?? "Active")")
		 Text("Injured: \(player.playerPoolEntry.player.injured ? "Yes" : "No")")
		 if let injuryStatus = player.playerPoolEntry.player.injuryStatus {
			Text("Injury Status: \(injuryStatus)")
		 }
	  }
   }

   private var statsSection: some View {
	  VStack(alignment: .leading, spacing: 5) {
		 Text("Stats")
			.font(.headline)
		 Text("Total Points: \(player.playerPoolEntry.appliedStatTotal, specifier: "%.2f")")
		 ForEach(player.playerPoolEntry.player.stats, id: \.id) { stat in
			VStack(alignment: .leading, spacing: 3) {
			   Text("Week \(stat.scoringPeriodId)")
				  .fontWeight(.semibold)
			   ForEach(stat.stats.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
				  Text("\(StatType(rawValue: key)?.name ?? "Unknown Stat"): \(value, specifier: "%.2f")")
			   }
			}
			Divider()
		 }
	  }
   }

   private var latestGameStatsSection: some View {
	  VStack(alignment: .leading, spacing: 5) {
		 Text("Latest Game Stats")
			.font(.headline)
		 if let latestStats = player.playerPoolEntry.player.stats.last {
			ForEach(latestStats.stats.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
			   Text("\(StatType(rawValue: key)?.name ?? "Unknown Stat"): \(value, specifier: "%.2f")")
			}
		 }
	  }
   }
}
