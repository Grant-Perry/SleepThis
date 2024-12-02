import SwiftUI

struct FantasyMatchupCardView: View {
   let matchup: AnyFantasyMatchup
   let fantasyViewModel: FantasyMatchupViewModel

   var body: some View {
	  VStack(spacing: 0) {
		 VStack {
			// CHANGE: Remove matchupStatusBar to reduce height
			// matchupStatusBar
			teamMatchupSection
			// CHANGE: Remove matchupInfoSection to reduce height
			// matchupInfoSection
		 }
		 // CHANGE: Reduce vertical padding
		 .padding(.vertical, 4) // Changed from 8
		 .padding(.horizontal, 12)
		 .cornerRadius(16)
		 .overlay(
			RoundedRectangle(cornerRadius: 16)
			   .stroke(Color.gray, lineWidth: 1)
		 )
		 .background(
			LinearGradient(gradient: Gradient(colors: [.gpBlueDarkL, .clear]), startPoint: .top, endPoint: .bottom)
			   .clipShape(RoundedRectangle(cornerRadius: 16))
		 )
		 .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
	  }
	  .padding(.horizontal, 4)
   }

   private var matchupStatusBar: some View {
	  HStack {
		 HStack(spacing: 4) {
			Circle()
			   .fill(Color.green)
			   .frame(width: 8, height: 8)
			Text("LIVE")
			   .font(.caption)
			   .fontWeight(.semibold)
			   .foregroundColor(.green)
		 }

		 Spacer()

		 Text("Week \(fantasyViewModel.selectedWeek)")
			.font(.caption)
			.foregroundColor(.secondary)
	  }
   }

   private var teamMatchupSection: some View {
	  HStack(alignment: .center, spacing: 20) {
		 let isESPNLeague = fantasyViewModel.leagueID == AppConstants.ESPNLeagueID[1]
		 let awayTeamScore = fantasyViewModel.getScore(for: matchup, teamIndex: isESPNLeague ? 0 : 0)
		 let homeTeamScore = fantasyViewModel.getScore(for: matchup, teamIndex: isESPNLeague ? 1 : 1)
		 let awayTeamIsWinning = awayTeamScore > homeTeamScore
		 let homeTeamIsWinning = homeTeamScore > awayTeamScore

		 FantasyTeamHeaderView(
			managerName: matchup.managerNames[isESPNLeague ? 0 : 1],
			score: awayTeamScore,
			avatarURL: matchup.avatarURLs[isESPNLeague ? 0 : 1],
			isWinning: awayTeamIsWinning
		 )
		 .frame(height: 60) // Add this to reduce height

		 VStack(spacing: 4) { // Reduced spacing
			Text("VS")
			   .font(.caption2) // Reduced font size
			   .foregroundColor(.secondary)

			Text(String(format: "%.2f", abs(awayTeamScore - homeTeamScore)))
			   .font(.caption2)
			   .foregroundColor(awayTeamIsWinning ? .gpGreen : .gpGreen)
		 }

		 FantasyTeamHeaderView(
			managerName: matchup.managerNames[isESPNLeague ? 1 : 0],
			score: homeTeamScore,
			avatarURL: matchup.avatarURLs[isESPNLeague ? 1 : 0],
			isWinning: homeTeamIsWinning
		 )
		 .frame(height: 135) // Add this to reduce height
	  }
	  // CHANGE: Reduce vertical padding
	  .padding(.vertical, 4) // Changed from 8
   }

   private var matchupInfoSection: some View {
	  HStack {
		 Text(fantasyViewModel.leagueName)
			.font(.caption)
			.foregroundColor(.secondary)

		 Spacer()

		 Image(systemName: "chevron.right")
			.font(.caption)
			.foregroundColor(.secondary)
	  }
   }
}
