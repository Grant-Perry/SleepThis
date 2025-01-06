import SwiftUI

struct FantasyPlayerCard: View {
   let player: PlayerModel
   let fantasyViewModel: FantasyMatchupViewModel
   @ObservedObject var nflScheduleViewModel: NFLScheduleViewModel

   var body: some View {
	  VStack {
		 // Existing player info...
		 Text("\(player.firstName ?? "") \(player.lastName ?? "")")
			.font(.headline)

		 // Fetch matchup info
		 if let team = player.team,
			let matchup = nflScheduleViewModel.getTeamMatchup(for: team) {

			// "BUF vs. KC - Sunday 4PM"
			Text("\(matchup.awayAbbrev) vs. \(matchup.homeAbbrev) - \(matchup.dayOfWeek) \(matchup.displayTime)")
			   .font(.system(size: 12))
			   .foregroundColor(.white)

			// If live game, show scores
			if matchup.status == .inProgress {
			   Text("\(matchup.awayScore ?? 0) - \(matchup.homeScore ?? 0)")
				  .font(.system(size: 12))
				  .foregroundColor(.white)
				  .padding(.top, 2)
			}

		 } else {
			// If no matchup found, you could show something else, or nothing at all.
		 }
	  }
	  // Apply green shadow if game is live
	  .shadow(color: isGameLive ? .green : .clear, radius: isGameLive ? 10 : 0)
   }

   private var isGameLive: Bool {
	  if let team = player.team,
		 let matchup = nflScheduleViewModel.getTeamMatchup(for: team) {
		 return matchup.status == .inProgress
	  }
	  return false
   }
}
