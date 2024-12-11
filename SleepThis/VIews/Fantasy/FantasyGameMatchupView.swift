import SwiftUI

// This view displays the matchup data for the specified team. If liveMatchup is true,
// it outlines the player card in green. Just add this view inside your existing code as needed.
// teamAbbreviation: The NFL team abbreviation, e.g. "BUF"
// refreshInterval: Time in seconds to auto refresh. 0 = off
struct FantasyGameMatchupView: View {
   @StateObject private var fantasyGameMatchupViewModel = FantasyMatchups.FantasyGameMatchupViewModel()

   let teamAbbreviation: String
   let refreshInterval: Int

   init(teamAbbreviation: String, refreshInterval: Int = 0) {
	  self.teamAbbreviation = teamAbbreviation
	  self.refreshInterval = refreshInterval
   }

   var body: some View {
	  VStack(alignment: .leading, spacing: 4) {
		 HStack(spacing: 4) {
			Text("\(fantasyGameMatchupViewModel.awayTeamAbbrev) v \(fantasyGameMatchupViewModel.homeTeamAbbrev) | \(fantasyGameMatchupViewModel.awayScore)-\(fantasyGameMatchupViewModel.homeScore)")
			   .font(.caption)
			   .foregroundColor(.white)
		 }

		 Text(fantasyGameMatchupViewModel.quarterTime)
			.font(.caption2)
			.foregroundColor(.white)

		 Text(fantasyGameMatchupViewModel.dayTime)
			.font(.caption2)
			.foregroundColor(.white)
	  }
	  .padding(4)
	  .background(
		 RoundedRectangle(cornerRadius: 6)
			.fill(Color.black.opacity(0.3))
			.overlay(
			   RoundedRectangle(cornerRadius: 6)
				  .stroke(fantasyGameMatchupViewModel.liveMatchup ? Color.green : Color.clear, lineWidth: 2)
			)
	  )
	  .onAppear {
		 fantasyGameMatchupViewModel.configure(teamAbbreviation: teamAbbreviation, refreshInterval: refreshInterval)
	  }
   }
}
