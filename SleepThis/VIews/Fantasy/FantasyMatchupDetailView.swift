import SwiftUI

struct FantasyMatchupDetailView: View {
   let matchup: AnyFantasyMatchup
   @ObservedObject var fantasyViewModel: FantasyMatchupViewModel
   let leagueName: String

   var body: some View {
	  let awayTeamScore = fantasyViewModel.getScore(for: matchup, teamIndex: 1)
	  let homeTeamScore = fantasyViewModel.getScore(for: matchup, teamIndex: 0)
	  let awayTeamIsWinning = awayTeamScore > homeTeamScore
	  let homeTeamIsWinning = homeTeamScore > awayTeamScore

	  VStack(spacing: 0) {
		 Text("Matchup Details")
			.font(.title2)
			.fontWeight(.bold)
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.horizontal)
			.padding(.top)

		 FantasyDetailHeaderView(
			leagueName: leagueName,
			matchup: matchup,
			awayTeamIsWinning: awayTeamIsWinning,
			homeTeamIsWinning: homeTeamIsWinning,
			fantasyViewModel: fantasyViewModel
		 )
		 .frame(height: 140)
		 .background(Color(.secondarySystemBackground))
		 .cornerRadius(16)
		 .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
		 .padding(.horizontal)
		 .padding(.vertical, 8)

		 ScrollView {
			VStack(spacing: 16) {
			   fantasyViewModel.activeRosterSection(matchup: matchup)
			   fantasyViewModel.benchSection(matchup: matchup)
			}
			.padding(.top, 8)
		 }
		 .background(Color(.systemGroupedBackground).ignoresSafeArea())
	  }
	  .navigationBarTitleDisplayMode(.inline)
   }
}
