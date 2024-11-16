import SwiftUI

struct FantasyMatchupDetailView: View {
   let matchup: AnyFantasyMatchup
   @ObservedObject var fantasyViewModel: FantasyMatchupViewModel
   let leagueName: String

   var body: some View {
	  VStack {
		 // Header with Team Names and Scores
		 HStack {
			VStack(alignment: .leading) {
			   Text(matchup.managerNames[0]) // Display manager name
				  .font(.system(size: 25, weight: .bold))
				  .foregroundColor(.pink)
			   Text("\(fantasyViewModel.getScore(for: matchup, teamIndex: 0), specifier: "%.2f")")
				  .font(.system(size: 30, weight: .bold))
				  .foregroundColor(fantasyViewModel.getScore(for: matchup, teamIndex: 0) > fantasyViewModel.getScore(for: matchup, teamIndex: 1) ? .gpGreen : .primary)
			}
			Spacer()
			VStack(alignment: .trailing) {
			   Text(matchup.managerNames[1]) // Display manager name
				  .font(.system(size: 25, weight: .bold))
				  .foregroundColor(.pink)
			   Text("\(fantasyViewModel.getScore(for: matchup, teamIndex: 1), specifier: "%.2f")")
				  .font(.system(size: 30, weight: .bold))
				  .foregroundColor(fantasyViewModel.getScore(for: matchup, teamIndex: 1) > fantasyViewModel.getScore(for: matchup, teamIndex: 0) ? .gpGreen : .primary)
			}
		 }
		 .padding()

		 ScrollView {
			// Active Roster Section
			Text("Active Roster")
			   .font(.headline)
			   .padding()
			   .frame(maxWidth: .infinity, alignment: .leading)
			   .frame(height: 35)
			   .background(LinearGradient(gradient: Gradient(colors: [.gpBlueDark, .clear]), startPoint: .top, endPoint: .bottom))
			   .foregroundColor(.white)

			HStack(alignment: .top, spacing: 16) {
			   rosterView(for: matchup, teamIndex: 0, isBench: false)
			   Spacer()
			   rosterView(for: matchup, teamIndex: 1, isBench: false)
			}
			.padding(.horizontal)

			// Bench Roster Section
			Text("Bench Roster")
			   .font(.headline)
			   .padding()
			   .frame(maxWidth: .infinity, alignment: .leading)
			   .frame(height: 35)
			   .background(LinearGradient(gradient: Gradient(colors: [.gpDark1, .clear]), startPoint: .top, endPoint: .bottom))
			   .foregroundColor(.white)

			HStack(alignment: .top, spacing: 16) {
			   rosterView(for: matchup, teamIndex: 0, isBench: true)
			   Spacer()
			   rosterView(for: matchup, teamIndex: 1, isBench: true)
			}
			.padding(.horizontal)
		 }
	  }
	  .navigationTitle(leagueName) // Display the league name directly
   }

   private func rosterView(for matchup: AnyFantasyMatchup, teamIndex: Int, isBench: Bool) -> some View {
	  // Only swap for ESPN leagues
	  let adjustedTeamIndex = fantasyViewModel.leagueID == AppConstants.ESPNLeagueID ?
	  (teamIndex == 0 ? 1 : 0) : teamIndex

	  let roster = fantasyViewModel.getRoster(for: matchup, teamIndex: adjustedTeamIndex, isBench: isBench)

	  // Calculate scores for color comparison
	  let score = roster.reduce(0) { $0 + fantasyViewModel.getPlayerScore(for: $1, week: fantasyViewModel.selectedWeek) }
	  let opposingRoster = fantasyViewModel.getRoster(for: matchup, teamIndex: adjustedTeamIndex == 0 ? 1 : 0, isBench: isBench)
	  let opposingScore = opposingRoster.reduce(0) { $0 + fantasyViewModel.getPlayerScore(for: $1, week: fantasyViewModel.selectedWeek) }

	  return VStack(alignment: .leading, spacing: 16) {
		 ForEach(roster, id: \.playerPoolEntry.player.id) { playerEntry in
			playerCard(for: playerEntry, isBench: isBench)
		 }

		 Text("Total \(isBench ? "Bench" : "Active"): \(score, specifier: "%.2f")")
			.font(.system(size: 20, weight: .medium))
			.foregroundColor(score > opposingScore ? .gpGreen : .primary)
			.frame(maxWidth: .infinity, alignment: .trailing)
			.padding(.top, 8)
	  }
   }

   private func playerCard(for playerEntry: FantasyScores.FantasyModel.Team.PlayerEntry, isBench: Bool) -> some View {
	  VStack {
		 HStack {
			if fantasyViewModel.leagueID == AppConstants.ESPNLeagueID {
			   LivePlayerImageView(
				  playerID: playerEntry.playerPoolEntry.player.id,
				  picSize: 65
			   )
			   .frame(width: 65, height: 65)
			} else {
			   AsyncImage(url: URL(string: "https://sleepercdn.com/content/nfl/players/\(playerEntry.playerPoolEntry.player.id).jpg")) { phase in
				  switch phase {
					 case .empty:
						Image(systemName: "american.football")
						   .resizable()
						   .frame(width: 25, height: 25)
					 case .success(let image):
						image
						   .resizable()
						   .scaledToFill()
						   .frame(width: 65, height: 65)
					 case .failure:
						Image(systemName: "american.football")
						   .resizable()
						   .frame(width: 25, height: 25)
					 @unknown default:
						EmptyView()
				  }
			   }
			   .frame(width: 65, height: 65)
			}

			VStack(alignment: .leading) {
			   Text(playerEntry.playerPoolEntry.player.fullName)
				  .font(.body)
				  .bold()
				  .frame(maxWidth: .infinity, alignment: .leading)
				  .lineLimit(1)
				  .minimumScaleFactor(0.5)

			   Text(positionString(playerEntry.lineupSlotId))
				  .font(.system(size: 10, weight: .light))
				  .foregroundColor(.primary)
				  .frame(maxWidth: .infinity, alignment: .leading)
			   HStack {
				  let playerScore = fantasyViewModel.getPlayerScore(for: playerEntry, week: fantasyViewModel.selectedWeek)
				  Text("\(playerScore, specifier: "%.2f")")
					 .font(.system(size: playerScore == 0 ? 15 : 20, weight: .medium))
					 .foregroundColor(.secondary)
					 .padding(.trailing)
					 .offset(x: 25, y: -9)
			   }
			   .frame(maxWidth: .infinity, alignment: .trailing)
			   .padding(.trailing)
			}
		 }
		 .padding(.vertical, 4)
		 .background(LinearGradient(gradient: Gradient(colors: [isBench ? .gpBlueLight : .gpBlueDark, .clear]), startPoint: .top, endPoint: .bottom))
		 .cornerRadius(10)
		 .opacity(isBench ? 0.75 : 1)
	  }
   }

   private func positionString(_ lineupSlotId: Int) -> String {
	  switch lineupSlotId {
		 case 0: return "QB"
		 case 2, 3: return "RB"
		 case 4, 5: return "WR"
		 case 6: return "TE"
		 case 16: return "D/ST"
		 case 17: return "K"
		 case 23: return "FLEX"
		 default: return ""
	  }
   }
}
