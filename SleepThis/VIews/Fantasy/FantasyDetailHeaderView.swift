import SwiftUI

struct FantasyDetailHeaderView: View {
   let leagueName: String
   let matchup: AnyFantasyMatchup
   let awayTeamIsWinning: Bool
   let homeTeamIsWinning: Bool
   @ObservedObject var fantasyViewModel: FantasyMatchupViewModel

   var body: some View {
	  ZStack {
		 LinearGradient(
			gradient: Gradient(colors: [.clear, .purple.opacity(0.2)]),
			startPoint: .bottom,
			endPoint: .top
		 )
		 .frame(height: 80)

		 RoundedRectangle(cornerRadius: 16)
			.fill(Color.black.opacity(0.2))

		 VStack(spacing: 4) {
			Text(leagueName)
			   .font(.system(size: 12))
			   .foregroundColor(.gray)
			   .padding(.top, 4)

			HStack(spacing: 16) {
			   fantasyViewModel.teamHeaderView(for: matchup, index: 0, isWinning: awayTeamIsWinning)
				  .onTapGesture {
					 fantasyViewModel.updateSelectedManager(matchup.awayTeamID.description)
				  }

			   VStack(spacing: 2) {
				  Text("VS")
					 .font(.system(size: 13, weight: .semibold))
					 .foregroundColor(.gray)

				  Text("Week \(fantasyViewModel.selectedWeek)")
					 .font(.system(size: 10))
					 .foregroundColor(.gray)

				  Text(fantasyViewModel.scoreDifferenceText(matchup: matchup))
					 .font(.system(size: 10, weight: .bold))
					 .foregroundColor(.gpGreen)
					 .padding(.horizontal, 6)
					 .padding(.vertical, 2)
					 .background(
						RoundedRectangle(cornerRadius: 6)
						   .fill(Color.black.opacity(0.2))
					 )
			   }
			   .padding(.vertical, 2)

			   fantasyViewModel.teamHeaderView(for: matchup, index: 1, isWinning: homeTeamIsWinning)
				  .onTapGesture {
					 fantasyViewModel.updateSelectedManager(matchup.homeTeamID.description)
				  }
			}
			.padding(.horizontal)
			.padding(.bottom, 4)
		 }
	  }
   }
}
