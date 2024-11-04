//import SwiftUI
//
//struct FantasyTeamRosterView: View {
//   let team: ESPNFantasy.ESPNFantasyModel.Team
//   let week: Int
//   let isActive: Bool
//
//   var body: some View {
//	  VStack(alignment: .leading, spacing: 8) {
//		 ForEach(team.roster?.entries.filter {
//			isActive ? ($0.lineupSlotId < 20 || $0.lineupSlotId == 23) : ($0.lineupSlotId >= 20 && $0.lineupSlotId != 23)
//		 } ?? [], id: \.playerPoolEntry.player.id) { playerEntry in
//			ESPNFantasyPlayerView(playerEntry: playerEntry, week: week)
//			   .padding(.vertical, 4)
//			   .background(isActive ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
//			   .cornerRadius(8)
//		 }
//		 let score = team.roster?.entries.filter {
//			isActive ? ($0.lineupSlotId < 20 || $0.lineupSlotId == 23) : ($0.lineupSlotId >= 20 && $0.lineupSlotId != 23)
//		 }.reduce(0) {
//			$0 + ($1.playerPoolEntry.player.stats.first { $0.scoringPeriodId == week && $0.statSourceId == 0 }?.appliedTotal ?? 0)
//		 } ?? 0
//		 Text("Total Score: \(score, specifier: "%.2f")")
//			.font(.subheadline)
//			.foregroundColor(.primary)
//	  }
//   }
//}
