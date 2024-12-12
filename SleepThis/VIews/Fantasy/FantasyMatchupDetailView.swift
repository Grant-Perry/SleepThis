// #fuc
// This version of FantasyMatchupDetailView breaks down the large expression into smaller sub-expressions
// to avoid the compiler complexity issue. We do this by separating some logic into smaller computed properties
// and functions, rather than inline calculations.

import SwiftUI

struct FantasyMatchupDetailView: View {
   let matchup: AnyFantasyMatchup
   @ObservedObject var fantasyViewModel: FantasyMatchupViewModel
   let leagueName: String

   var body: some View {
	  let awayTeamScore = fantasyViewModel.getScore(for: matchup, teamIndex: 0)
	  let homeTeamScore = fantasyViewModel.getScore(for: matchup, teamIndex: 1)
	  let awayTeamIsWinning = awayTeamScore > homeTeamScore
	  let homeTeamIsWinning = homeTeamScore > awayTeamScore

	  VStack(spacing: 0) {
		 topHeaderSection(
			leagueName: leagueName,
			matchup: matchup,
			awayTeamIsWinning: awayTeamIsWinning,
			homeTeamIsWinning: homeTeamIsWinning
		 )
		 .background(Color(.secondarySystemBackground))
		 .cornerRadius(16)
		 .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
		 .padding(.horizontal)
		 .padding(.top)

		 ScrollView {
			VStack(spacing: 16) {
			   activeRosterSection(matchup: matchup)
			   benchSection(matchup: matchup)
			}
			.padding(.vertical)
		 }
		 .background(Color(.systemGroupedBackground).ignoresSafeArea())
		 .navigationTitle("Matchup Details")
	  }
   }

   // MARK: Top Header Section
   private func topHeaderSection(
	  leagueName: String,
	  matchup: AnyFantasyMatchup,
	  awayTeamIsWinning: Bool,
	  homeTeamIsWinning: Bool
   ) -> some View {
	  VStack(spacing: 0) {
		 Text(leagueName)
			.font(.caption)
			.foregroundColor(.secondary)
			.padding(.top)

		 HStack {
			// Away/Visitor Team
			teamHeaderViewForIndex(0, matchup: matchup, isWinning: awayTeamIsWinning)
			   .onTapGesture {
				  fantasyViewModel.updateSelectedManager(matchup.awayTeamID.description)
			   }

			VStack {
			   Text("VS")
				  .font(.headline)
				  .foregroundColor(.secondary)
			   Text("Week \(fantasyViewModel.selectedWeek)")
				  .font(.caption)
				  .foregroundColor(.secondary)
			   Text(scoreDifferenceText(matchup: matchup))
				  .font(.caption2)
				  .foregroundColor(.gpGreen)
			}

			// Home Team
			teamHeaderViewForIndex(1, matchup: matchup, isWinning: homeTeamIsWinning)
			   .onTapGesture {
				  fantasyViewModel.updateSelectedManager(matchup.homeTeamID.description)
			   }
		 }
		 .padding()
	  }
   }

   // MARK: Team Header View
   private func teamHeaderViewForIndex(_ index: Int, matchup: AnyFantasyMatchup, isWinning: Bool) -> some View {
	  FantasyTeamHeaderView(
		 managerName: getManagerName(teamIndex: index),
		 score: fantasyViewModel.getScore(for: matchup, teamIndex: index),
		 avatarURL: getAvatarURL(teamIndex: index),
		 isWinning: isWinning
	  )
   }

   // MARK: Active Roster Section
   private func activeRosterSection(matchup: AnyFantasyMatchup) -> some View {
	  VStack(alignment: .leading, spacing: 12) {
		 Text("Active Roster")
			.font(.headline)
			.padding(.horizontal)

		 HStack(alignment: .top, spacing: 16) {
			// Away/Visitor Team Active Roster
			VStack(spacing: 8) {
			   let awayActiveRoster = fantasyViewModel.getRoster(for: matchup, teamIndex: 0, isBench: false)
			   ForEach(awayActiveRoster, id: \.playerPoolEntry.player.id) { player in
				  FantasyPlayerCard(player: player, fantasyViewModel: fantasyViewModel)
			   }

			   Text("Active Total: \(formattedScore(fantasyViewModel.getScore(for: matchup, teamIndex: 0)))")
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

			// Home Team Active Roster
			VStack(spacing: 8) {
			   let homeActiveRoster = fantasyViewModel.getRoster(for: matchup, teamIndex: 1, isBench: false)
			   ForEach(homeActiveRoster, id: \.playerPoolEntry.player.id) { player in
				  FantasyPlayerCard(player: player, fantasyViewModel: fantasyViewModel)
			   }

			   Text("Active Total: \(formattedScore(fantasyViewModel.getScore(for: matchup, teamIndex: 1)))")
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
		 .padding(.horizontal)
	  }
   }

   // MARK: Bench Section
   private func benchSection(matchup: AnyFantasyMatchup) -> some View {
	  VStack(alignment: .leading, spacing: 12) {
		 Text("Bench")
			.font(.headline)
			.padding(.horizontal)

		 HStack(alignment: .top, spacing: 16) {
			// Away/Visitor Team Bench
			VStack(spacing: 8) {
			   let awayBenchRoster = fantasyViewModel.getRoster(for: matchup, teamIndex: 0, isBench: true)
			   ForEach(awayBenchRoster, id: \.playerPoolEntry.player.id) { player in
				  FantasyPlayerCard(player: player, fantasyViewModel: fantasyViewModel)
			   }

			   Text("Bench Total: \(formattedScore(awayBenchRoster.reduce(0.0) { $0 + fantasyViewModel.getPlayerScore(for: $1, week: fantasyViewModel.selectedWeek) }))")
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

			// Home Team Bench
			VStack(spacing: 8) {
			   let homeBenchRoster = fantasyViewModel.getRoster(for: matchup, teamIndex: 1, isBench: true)
			   ForEach(homeBenchRoster, id: \.playerPoolEntry.player.id) { player in
				  FantasyPlayerCard(player: player, fantasyViewModel: fantasyViewModel)
			   }

			   Text("Bench Total: \(formattedScore(homeBenchRoster.reduce(0.0) { $0 + fantasyViewModel.getPlayerScore(for: $1, week: fantasyViewModel.selectedWeek) }))")
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
		 .padding(.horizontal)
	  }
   }

   // MARK: Helper Functions
   private func scoreDifferenceText(matchup: AnyFantasyMatchup) -> String {
	  let awayTeamScore = fantasyViewModel.getScore(for: matchup, teamIndex: 0)
	  let homeTeamScore = fantasyViewModel.getScore(for: matchup, teamIndex: 1)
	  return String(format: "%.2f", abs(awayTeamScore - homeTeamScore))
   }

   private func formattedScore(_ score: Double) -> String {
	  return String(format: "%.2f", score)
   }

   private func getManagerName(teamIndex: Int) -> String {
	  if fantasyViewModel.leagueID == AppConstants.ESPNLeagueID[1] {
		 return matchup.managerNames[teamIndex]
	  } else {
		 return matchup.managerNames[teamIndex == 0 ? 1 : 0]
	  }
   }

   private func getAvatarURL(teamIndex: Int) -> URL? {
	  if fantasyViewModel.leagueID == AppConstants.ESPNLeagueID[1] {
		 return matchup.avatarURLs[teamIndex]
	  } else {
		 return matchup.avatarURLs[teamIndex == 0 ? 1 : 0]
	  }
   }
}
