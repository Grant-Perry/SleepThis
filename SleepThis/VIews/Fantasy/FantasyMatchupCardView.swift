import SwiftUI

struct FantasyMatchupCardView: View {
   let matchup: AnyFantasyMatchup
   let fantasyViewModel: FantasyMatchupViewModel

   var body: some View {
	  VStack(spacing: 0) {
		 VStack {
			matchupStatusBar
			teamMatchupSection
			matchupInfoSection
		 }
		 .padding(.vertical, 8)
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
		 // Away Team
		 let awayTeamScore = fantasyViewModel.getScore(for: matchup, teamIndex: 1)
		 let homeTeamScore = fantasyViewModel.getScore(for: matchup, teamIndex: 0)
		 let awayTeamIsWinning = awayTeamScore > homeTeamScore
		 let homeTeamIsWinning = homeTeamScore > awayTeamScore

		 FantasyTeamHeaderView(
			managerName: matchup.managerNames[1],
			score: homeTeamScore,
			avatarURL: matchup.avatarURLs[1],
			isWinning: homeTeamIsWinning
		 )

		 VStack(spacing: 8) {
			Text("VS")
			   .font(.caption)
			   .foregroundColor(.secondary)

			Text(String(format: "%.2f", homeTeamScore - awayTeamScore))
			   .font(.caption2)
			   .foregroundColor(homeTeamIsWinning ? .green : .red)
		 }

		 // Home Team
		 FantasyTeamHeaderView(
			managerName: matchup.managerNames[0],
			score: awayTeamScore,
			avatarURL: matchup.avatarURLs[0],
			isWinning: awayTeamIsWinning
		 )
	  }
	  .padding(.vertical, 8)
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
