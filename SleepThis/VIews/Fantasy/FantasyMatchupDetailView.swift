import SwiftUI

struct FantasyMatchupDetailView: View {
   let matchup: AnyFantasyMatchup
   @ObservedObject var fantasyViewModel: FantasyMatchupViewModel
   let leagueName: String

   var body: some View {
	  VStack(spacing: 0) {
		 // Fixed Header
		 VStack(spacing: 0) {
			// Fixed Header
			VStack(spacing: 0) {
			   Text(leagueName)
				  .font(.caption)
				  .foregroundColor(.secondary)
				  .padding(.top)
			   
			   HStack {
				  // Away/Visitor Team
				  FantasyTeamHeaderView(
					 managerName: getManagerName(teamIndex: 0),
					 score: fantasyViewModel.getScore(for: matchup, teamIndex: 0),
					 avatarURL: getAvatarURL(teamIndex: 0),
					 isWinning: fantasyViewModel.getScore(for: matchup, teamIndex: 0) >
					 fantasyViewModel.getScore(for: matchup, teamIndex: 1)
				  )
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
				  }
				  
				  // Home Team
				  FantasyTeamHeaderView(
					 managerName: getManagerName(teamIndex: 1),
					 score: fantasyViewModel.getScore(for: matchup, teamIndex: 1),
					 avatarURL: getAvatarURL(teamIndex: 1),
					 isWinning: fantasyViewModel.getScore(for: matchup, teamIndex: 1) >
					 fantasyViewModel.getScore(for: matchup, teamIndex: 0)
				  )
				  .onTapGesture {
					 fantasyViewModel.updateSelectedManager(matchup.homeTeamID.description)
				  }
			   }
			   .padding()
			}
			.background(Color(.secondarySystemBackground))
			.cornerRadius(16)
			.shadow(color: .black.opacity(0.1), radius: 5)
			.padding(.horizontal)
			.padding(.top)
			
			// Scrollable Content
			ScrollView {
			   VStack(spacing: 16) {
				  // Active Roster Section
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
						   
						   // Away Team Active Total
						   Text("Active Total: \(String(format: "%.2f", fantasyViewModel.getScore(for: matchup, teamIndex: 0)))")
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
						   
						   // Home Team Active Total
						   Text("Active Total: \(String(format: "%.2f", fantasyViewModel.getScore(for: matchup, teamIndex: 1)))")
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
				  
				  // Bench Section
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
						   
						   // Away Team Bench Total
						   Text("Bench Total: \(String(format: "%.2f", awayBenchRoster.reduce(0.0) { $0 + fantasyViewModel.getPlayerScore(for: $1, week: fantasyViewModel.selectedWeek) }))")
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
						   
						   // Home Team Bench Total
						   Text("Bench Total: \(String(format: "%.2f", homeBenchRoster.reduce(0.0) { $0 + fantasyViewModel.getPlayerScore(for: $1, week: fantasyViewModel.selectedWeek) }))")
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
			   .padding(.vertical)
			}
		 }
		 .background(Color(.systemGroupedBackground).ignoresSafeArea())
		 .navigationTitle("Matchup Details")
	  }
   }

   // Helper functions for Sleeper-specific logic
   private func getManagerName(teamIndex: Int) -> String {
	  if fantasyViewModel.leagueID == AppConstants.ESPNLeagueID[1] {
		 return matchup.managerNames[teamIndex]
	  } else {
		 // Swap manager names for Sleeper leagues
		 return matchup.managerNames[teamIndex == 0 ? 1 : 0]
	  }
   }

   private func getAvatarURL(teamIndex: Int) -> URL? {
	  if fantasyViewModel.leagueID == AppConstants.ESPNLeagueID[1] {
		 return matchup.avatarURLs[teamIndex]
	  } else {
		 // Swap avatar URLs for Sleeper leagues
		 return matchup.avatarURLs[teamIndex == 0 ? 1 : 0]
	  }
   }
}
