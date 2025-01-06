import SwiftUI

struct FantasyMatchupDetailView: View {
   let matchup: AnyFantasyMatchup
   @ObservedObject var fantasyViewModel: FantasyMatchupViewModel
   @ObservedObject var nflScheduleViewModel: NFLScheduleViewModel
   let leagueName: String

   var body: some View {
	  VStack(spacing: 0) {
		 headerView
		 ScrollView {
			VStack(spacing: 16) {
			   activeRosterSection
			   benchRosterSection
			}
			.padding(.vertical)
		 }
	  }
	  .background(Color(.systemGroupedBackground).ignoresSafeArea())
	  .navigationTitle("Matchup Details")
   }

   private var headerView: some View {
	  VStack(spacing: 0) {
		 Text(leagueName)
			.font(.caption)
			.foregroundColor(.secondary)
			.padding(.top)

		 HStack {
			teamHeader(for: matchup.awayTeamID, score: matchup.scores[0], isHome: false)
			Spacer()
			VStack {
			   Text("VS")
				  .font(.headline)
				  .foregroundColor(.secondary)
			   Text("Week \(fantasyViewModel.selectedWeek)")
				  .font(.caption)
				  .foregroundColor(.secondary)
			}
			Spacer()
			teamHeader(for: matchup.homeTeamID, score: matchup.scores[1], isHome: true)
		 }
		 .padding()
	  }
	  .background(Color(.secondarySystemBackground))
	  .cornerRadius(16)
	  .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
	  .padding(.horizontal)
	  .padding(.top)
   }

   private var activeRosterSection: some View {
	  VStack(alignment: .leading, spacing: 12) {
		 Text("Active Roster")
			.font(.headline)
			.padding(.horizontal)

		 HStack(alignment: .top, spacing: 16) {
			rosterColumn(for: 0, isBench: false)
			rosterColumn(for: 1, isBench: false)
		 }
		 .padding(.horizontal)
	  }
   }

   private var benchRosterSection: some View {
	  VStack(alignment: .leading, spacing: 12) {
		 Text("Bench")
			.font(.headline)
			.padding(.horizontal)

		 HStack(alignment: .top, spacing: 16) {
			rosterColumn(for: 0, isBench: true)
			rosterColumn(for: 1, isBench: true)
		 }
		 .padding(.horizontal)
	  }
   }

   private func teamHeader(for teamID: Int, score: Double, isHome: Bool) -> some View {
	  VStack {
		 Text(getTeamName(for: teamID, isHome: isHome))
			.font(.headline)
		 Text(String(format: "%.2f", score))
			.font(.caption)
			.foregroundColor(.secondary)
	  }
   }

   private func rosterColumn(for teamIndex: Int, isBench: Bool) -> some View {
	  VStack(spacing: 8) {
		 let roster = fantasyViewModel.getRoster(for: matchup, teamIndex: teamIndex, isBench: isBench)
		 ForEach(roster, id: \.playerPoolEntry.player.id) { playerEntry in
			if let playerModel = fantasyViewModel.playerViewModel.getPlayerInfo(by: String(playerEntry.playerPoolEntry.player.id)) {
			   FantasyPlayerCard(player: playerModel,
								 fantasyViewModel: fantasyViewModel,
								 nflScheduleViewModel: nflScheduleViewModel)
			}
		 }
		 Text("Total: \(String(format: "%.2f", calculateTotalScore(for: roster)))")
			.font(.subheadline)
			.fontWeight(.semibold)
			.frame(maxWidth: .infinity)
			.padding(.vertical, 8)
			.background(
			   LinearGradient(
				  gradient: Gradient(colors: [Color(.secondarySystemBackground), Color.clear]),
				  startPoint: .top,
				  endPoint: .bottom
			   )
			)
	  }
   }

   private func calculateTotalScore(for roster: [FantasyScores.FantasyModel.Team.PlayerEntry]) -> Double {
	  roster.reduce(0.0) { total, entry in
		 total + fantasyViewModel.getPlayerScore(for: entry, week: fantasyViewModel.selectedWeek)
	  }
   }

   private func getTeamName(for teamID: Int, isHome: Bool) -> String {
	  let team = isHome ? matchup.managerNames[1] : matchup.managerNames[0]
	  return team
   }
}
