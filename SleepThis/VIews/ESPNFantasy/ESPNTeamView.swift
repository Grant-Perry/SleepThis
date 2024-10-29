//import SwiftUI
//
//struct ESPNTeamView: View {
//   let team: ESPNFantasy.ESPNFantasyModel.Team
//   let isWinner: Bool
//
//   var body: some View {
//	  VStack(alignment: .leading) {
//		 Text(team.name) // Display actual team name
//			.font(.title)
//			.foregroundColor(isWinner ? .green : .primary)
//
//		 let totalPoints: Double = {
//			let entries = team.rosterForCurrentScoringPeriod?.entries ?? []
//			return entries.reduce(0) { $0 + ($1.playerPoolEntry.player.stats.first?.appliedTotal ?? 0) }
//		 }()
//
//		 Text("Total Points: \(totalPoints, specifier: "%.2f")")
//			.font(.subheadline)
//
//		 ForEach(team.rosterForCurrentScoringPeriod?.entries ?? [], id: \.playerPoolEntry.player.fullName) { player in
//			ESPNPlayerView(player: player.playerPoolEntry.player)
//		 }
//	  }
//   }
//}
