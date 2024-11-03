import SwiftUI

struct FantasyMatchupDetailView: View {
   let matchup: AnyFantasyMatchup
   @ObservedObject var fantasyViewModel: FantasyMatchupViewModel
   let selectedWeek: Int

   var body: some View {
	  VStack {
		 HStack {
			VStack(alignment: .leading) {
			   Text(matchup.teamNames[0])
				  .font(.title)
				  .bold()
			   Text("Score: \(fantasyViewModel.getScore(for: matchup, teamIndex: 0), specifier: "%.2f")")
				  .font(.headline)
			}
			Spacer()
			VStack(alignment: .trailing) {
			   Text(matchup.teamNames[1])
				  .font(.title)
				  .bold()
			   Text("Score: \(fantasyViewModel.getScore(for: matchup, teamIndex: 1), specifier: "%.2f")")
				  .font(.headline)
			}
		 }
		 .padding()

		 ScrollView {
			VStack(alignment: .leading, spacing: 10) {
			   Text("Team 1 Roster:")
				  .font(.headline)
			   rosterList(for: matchup, teamIndex: 0)

			   Text("Team 2 Roster:")
				  .font(.headline)
			   rosterList(for: matchup, teamIndex: 1)
			}
			.padding()
		 }
		 .background(Color(UIColor.systemGray6))
		 .cornerRadius(10)
		 .padding()
	  }
	  .navigationTitle("Matchup Detail")
	  .navigationBarTitleDisplayMode(.inline)
   }

   private func rosterList(for matchup: AnyFantasyMatchup, teamIndex: Int) -> some View {
	  VStack(alignment: .leading) {
		 ForEach(0..<5, id: \.self) { _ in
			HStack {
			   Text("Player Name")
			   Spacer()
			   Text("Points")
			}
			.padding(.vertical, 4)
			.background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemGray5)))
		 }
	  }
   }
}
