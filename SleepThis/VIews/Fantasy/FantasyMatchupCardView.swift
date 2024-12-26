import SwiftUI

struct FantasyMatchupCardView: View {
   @StateObject private var fantasyGameMatchupViewModel = FantasyGameMatchupViewModel()
   let matchup: AnyFantasyMatchup
   @ObservedObject var fantasyViewModel: FantasyMatchupViewModel
   var isLive: Bool {
	  fantasyGameMatchupViewModel.liveMatchup
   }
   
   private var isSleeperLeague: Bool {
	  if let league = fantasyViewModel.currentManagerLeagues.first(where: { $0.id == fantasyViewModel.leagueID }) {
		 return league.type == .sleeper
	  }
	  return false
   }
   
   var body: some View {
	  VStack(spacing: 0) {
		 VStack {
			HStack(spacing: 16) {
			   // MARK: Away team
			   FantasyManagerDetails(
				  managerName: matchup.managerNames[0],
				  managerRecord: fantasyViewModel.getManagerRecord(managerID: matchup.awayTeamID.description),
				  score: fantasyViewModel.getScore(for: matchup, teamIndex: 0),
				  isWinning: fantasyViewModel.getScore(for: matchup, teamIndex: 0) > fantasyViewModel.getScore(for: matchup, teamIndex: 1),
				  avatarURL: matchup.avatarURLs[0],
				  fantasyViewModel: fantasyViewModel,
				  rosterID: matchup.awayTeamID,
				  selectedYear: fantasyViewModel.selectedYear
			   )
			   
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
			   
			   // Home team
			   FantasyManagerDetails(
				  managerName: matchup.managerNames[1],
				  managerRecord: fantasyViewModel.getManagerRecord(managerID: matchup.homeTeamID.description),
				  score: fantasyViewModel.getScore(for: matchup, teamIndex: 1),
				  isWinning: fantasyViewModel.getScore(for: matchup, teamIndex: 1) > fantasyViewModel.getScore(for: matchup, teamIndex: 0),
				  avatarURL: matchup.avatarURLs[1],
				  fantasyViewModel: fantasyViewModel,
				  rosterID: matchup.homeTeamID,
				  selectedYear: fantasyViewModel.selectedYear
			   )
			}
			.padding()
			.background(Color(.secondarySystemBackground))
			.cornerRadius(16)
			.shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
		 }
		 .padding(.vertical, 4)
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
