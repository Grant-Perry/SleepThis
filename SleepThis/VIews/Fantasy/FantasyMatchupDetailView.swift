import SwiftUI

struct FantasyMatchupDetailView: View {
   let matchup: AnyFantasyMatchup
   @ObservedObject var fantasyViewModel: FantasyMatchupViewModel
   let selectedWeek: Int

   var body: some View {
	  VStack {
		 Text("\(matchup.teamNames[0]) vs \(matchup.teamNames[1])")
			.font(.largeTitle)
			.padding()

		 HStack {
			rosterView(for: matchup.teamNames[0], teamIndex: 0)
			Spacer()
			rosterView(for: matchup.teamNames[1], teamIndex: 1)
		 }
		 .padding()
	  }
	  .navigationTitle("Matchup Detail")
	  .onAppear {
		 fantasyViewModel.fetchFantasyMatchupViewModelMatchups()
	  }
   }

   private func rosterView(for teamName: String, teamIndex: Int) -> some View {
	  VStack(alignment: .leading) {
		 Text(teamName)
			.font(.headline)
			.padding(.bottom, 8)
		 ForEach(fantasyViewModel.getRoster(for: matchup, teamIndex: teamIndex), id: \.playerPoolEntry.player.id) { player in
			playerRow(for: player)
		 }
	  }
   }

   private func playerRow(for player: FantasyScores.FantasyModel.Team.PlayerEntry) -> some View {
	  HStack {
		 Text(player.playerPoolEntry.player.fullName)
			.font(.body)
		 Spacer()
		 Text("\(fantasyViewModel.getPlayerScore(for: player, week: selectedWeek), specifier: "%.2f") pts")
			.font(.subheadline)
			.foregroundColor(.secondary)
	  }
	  .padding(.vertical, 4)
   }
}
