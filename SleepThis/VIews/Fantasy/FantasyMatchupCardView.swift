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
		 .padding()
		 .background(Color(.secondarySystemBackground))
		 .cornerRadius(16)
		 .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
	  }
	  .padding(.horizontal)
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
		 FantasyTeamHeaderView(
			managerName: matchup.managerNames[0],
			score: fantasyViewModel.getScore(for: matchup, teamIndex: 0),
			avatarURL: matchup.avatarURLs[0],
			isWinning: fantasyViewModel.getScore(for: matchup, teamIndex: 0) >
			fantasyViewModel.getScore(for: matchup, teamIndex: 1)
		 )

		 VStack(spacing: 8) {
			Text("VS")
			   .font(.caption)
			   .foregroundColor(.secondary)
			Text("@")
			   .font(.caption2)
			   .foregroundColor(.secondary)
		 }

		 // Home Team
		 FantasyTeamHeaderView(
			managerName: matchup.managerNames[1],
			score: fantasyViewModel.getScore(for: matchup, teamIndex: 1),
			avatarURL: matchup.avatarURLs[1],
			isWinning: fantasyViewModel.getScore(for: matchup, teamIndex: 1) >
			fantasyViewModel.getScore(for: matchup, teamIndex: 0)
		 )
	  }
	  .padding(.vertical, 12)
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
