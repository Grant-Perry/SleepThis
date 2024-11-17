import SwiftUI

struct FantasyMatchupDetailView: View {
   let matchup: AnyFantasyMatchup
   @ObservedObject var fantasyViewModel: FantasyMatchupViewModel
   let leagueName: String

   var body: some View {
	  ScrollView {
		 VStack(spacing: 16) {
			// Header Card
			VStack(spacing: 0) {
			   Text(leagueName)
				  .font(.caption)
				  .foregroundColor(.secondary)
				  .padding(.top)

			   HStack {
				  // Away Team (first in array)
				  FantasyTeamHeaderView(
					 managerName: matchup.managerNames[0],
					 score: fantasyViewModel.getScore(for: matchup, teamIndex: 0),
					 avatarURL: matchup.avatarURLs[0],
					 isWinning: fantasyViewModel.getScore(for: matchup, teamIndex: 0) >
					 fantasyViewModel.getScore(for: matchup, teamIndex: 1)
				  )

				  VStack {
					 Text("VS")
						.font(.headline)
						.foregroundColor(.secondary)
					 Text("Week \(fantasyViewModel.selectedWeek)")
						.font(.caption)
						.foregroundColor(.secondary)
				  }

				  // Home Team (second in array)
				  FantasyTeamHeaderView(
					 managerName: matchup.managerNames[1],
					 score: fantasyViewModel.getScore(for: matchup, teamIndex: 1),
					 avatarURL: matchup.avatarURLs[1],
					 isWinning: fantasyViewModel.getScore(for: matchup, teamIndex: 1) >
					 fantasyViewModel.getScore(for: matchup, teamIndex: 0)
				  )
			   }
			   .padding()
			}
			.background(Color(.secondarySystemBackground))
			.cornerRadius(16)
			.shadow(color: .black.opacity(0.1), radius: 5)
			.padding(.horizontal)

			// Active Roster Section
			VStack(alignment: .leading, spacing: 12) {
			   Text("Active Roster")
				  .font(.headline)
				  .padding(.horizontal)

			   HStack(alignment: .top, spacing: 16) {
				  // Away Team Active Roster
				  VStack(spacing: 8) {
					 let awayActiveRoster = fantasyViewModel.getRoster(for: matchup, teamIndex: 0, isBench: false)
					 ForEach(awayActiveRoster, id: \.playerPoolEntry.player.id) { player in
						FantasyPlayerCard(player: player, fantasyViewModel: fantasyViewModel)
					 }

					 // Away Team Active Total
					 Text("Active Total: \(String(format: "%.2f", awayActiveRoster.reduce(0.0) { $0 + fantasyViewModel.getPlayerScore(for: $1, week: fantasyViewModel.selectedWeek) }))")
						.font(.subheadline)
						.fontWeight(.semibold)
						.padding(.top, 4)
				  }

				  // Home Team Active Roster
				  VStack(spacing: 8) {
					 let homeActiveRoster = fantasyViewModel.getRoster(for: matchup, teamIndex: 1, isBench: false)
					 ForEach(homeActiveRoster, id: \.playerPoolEntry.player.id) { player in
						FantasyPlayerCard(player: player, fantasyViewModel: fantasyViewModel)
					 }

					 // Home Team Active Total
					 Text("Active Total: \(String(format: "%.2f", homeActiveRoster.reduce(0.0) { $0 + fantasyViewModel.getPlayerScore(for: $1, week: fantasyViewModel.selectedWeek) }))")
						.font(.subheadline)
						.fontWeight(.semibold)
						.padding(.top, 4)
				  }
			   }
			   .padding(.horizontal)
			}

			// Bench Section
			VStack(alignment: .leading, spacing: 12) {
			   Text("Bench")
				  .font(.headline)
				  .padding(.horizontal)

			   HStack(alignment: .top, spacing: 16) {
				  // Away Team Bench
				  VStack(spacing: 8) {
					 let awayBenchRoster = fantasyViewModel.getRoster(for: matchup, teamIndex: 0, isBench: true)
					 ForEach(awayBenchRoster, id: \.playerPoolEntry.player.id) { player in
						FantasyPlayerCard(player: player, fantasyViewModel: fantasyViewModel)
					 }

					 // Away Team Bench Total
					 Text("Bench Total: \(String(format: "%.2f", awayBenchRoster.reduce(0.0) { $0 + fantasyViewModel.getPlayerScore(for: $1, week: fantasyViewModel.selectedWeek) }))")
						.font(.subheadline)
						.fontWeight(.semibold)
						.padding(.top, 4)
				  }

				  // Home Team Bench
				  VStack(spacing: 8) {
					 let homeBenchRoster = fantasyViewModel.getRoster(for: matchup, teamIndex: 1, isBench: true)
					 ForEach(homeBenchRoster, id: \.playerPoolEntry.player.id) { player in
						FantasyPlayerCard(player: player, fantasyViewModel: fantasyViewModel)
					 }

					 // Home Team Bench Total
					 Text("Bench Total: \(String(format: "%.2f", homeBenchRoster.reduce(0.0) { $0 + fantasyViewModel.getPlayerScore(for: $1, week: fantasyViewModel.selectedWeek) }))")
						.font(.subheadline)
						.fontWeight(.semibold)
						.padding(.top, 4)
				  }
			   }
			   .padding(.horizontal)
			}
		 }
		 .padding(.vertical)
	  }
	  .background(Color(.systemGroupedBackground).ignoresSafeArea())
	  .navigationTitle("Matchup Details")
   }
}


