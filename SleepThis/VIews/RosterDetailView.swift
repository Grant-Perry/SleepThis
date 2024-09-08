
import SwiftUI

struct RosterDetailView: View {
   let managerID: String
   let managerName: String
   let managerAvatarURL: URL?
   @ObservedObject var rosterViewModel: RosterViewModel
   let playerViewModel = PlayerViewModel()
   var playerSize = 50.0

   var body: some View {
	  ScrollView {
		 VStack(alignment: .leading, spacing: 10) {
			// Manager info: Avatar and Name
			HStack {
			   AsyncImage(url: managerAvatarURL) { image in
				  image.resizable()
					 .aspectRatio(contentMode: .fill)
					 .frame(width: playerSize, height: playerSize)
					 .clipShape(Circle())
			   } placeholder: {
				  Image(systemName: "person.crop.circle")
					 .resizable()
					 .frame(width: playerSize, height: playerSize)
			   }
			   VStack(alignment: .leading) {
				  Text(managerName)
					 .font(.title2)
			   }
			}
			.padding(.horizontal) // Ensure padding around the entire header section

			// Settings Section
			if let settings = rosterViewModel.getManagerSettings(managerID: managerID) {
			   VStack(spacing: 1) {
				  // First Row: Wins, Losses, Pts For, Against
				  HStack {
					 ManagerSettingsRow(label: "Wins:", value: "\(settings.wins)")
					 ManagerSettingsRow(label: "Losses:", value: "\(settings.losses)")
					 ManagerSettingsRow(label: "Pts For:", value: "\(settings.fpts)")
					 ManagerSettingsRow(label: "Against:", value: "\(settings.fptsAgainst ?? 0)")
				  }

				  // Second Row: Waiver Pos, Waiver Budget, Moves
				  HStack {
					 ManagerSettingsRow(label: "Waiv Pos:", value: "\(settings.waiverPosition)")
					 ManagerSettingsRow(label: "Budget:", value: "\(settings.waiverBudgetUsed)")
					 ManagerSettingsRow(label: "Moves:", value: "\(settings.totalMoves)")
					 ManagerSettingsRow(label: "", value: "") // Empty to fill the space
				  }
			   }
			   .padding(.horizontal) // Add horizontal padding to prevent bleed
			   .padding(.top, 16)
			}

			// Starters Section
			let starters = rosterViewModel.managerStarters(managerID: managerID)
			StarterListView(starters: starters, playerViewModel: playerViewModel)
			   .padding(.horizontal) // Add horizontal padding for starters

			// Bench Players Section
			let allPlayers = rosterViewModel.rosters.first(where: { $0.ownerID == managerID })?.players ?? []
			let benchPlayers = allPlayers.filter { !starters.contains($0) }
			BenchView(benchPlayers: benchPlayers, playerViewModel: playerViewModel)
			   .padding(.horizontal) // Add horizontal padding for bench
		 }
		 .padding(.horizontal)  // Added padding to prevent overflow on the screen edges
	  }
	  .navigationTitle("Roster Detail")
   }
}



struct RosterDetailView_Previews: PreviewProvider {
   static var previews: some View {
	  let sampleRosterSettings = RosterSettings(
		 division: 1,
		 fpts: 100,
		 fptsAgainst: 90,
		 losses: 1,
		 ties: 0,
		 totalMoves: 5,
		 waiverBudgetUsed: 0,
		 waiverPosition: 8,
		 wins: 10
	  )

	  let sampleRosterModel = RosterModel(
		 coOwners: nil,
		 keepers: nil,
		 leagueID: "12345",
		 metadata: nil,
		 ownerID: "sample_owner_id",
		 playerMap: nil,
		 players: ["1001", "1002", "1003", "1004"],
		 rosterID: 1,
		 settings: sampleRosterSettings,
		 starters: ["1001", "1002"],
		 taxi: nil
	  )

	  let rosterViewModel = RosterViewModel(leagueID: "12345")
	  rosterViewModel.rosters = [sampleRosterModel]

	  let playerViewModel = PlayerViewModel()
	  playerViewModel.players = [
		 PlayerModel(id: "1001", firstName: "Player", lastName: "One", fullName: "Player One", team: "ARI", position: "QB", age: 30, height: "6'1\"", weight: "210", status: "Active", college: "Some College", birthCity: nil, birthState: nil, birthCountry: "USA", birthDate: nil, yearsExp: 5, highSchool: nil, fantasyPositions: nil, metadata: nil, newsUpdated: nil, number: nil, depthChartPosition: nil, depthChartOrder: nil, rookieYear: nil, statsId: nil, searchLastName: nil, searchFirstName: nil, searchFullName: nil, hashtag: nil, injuryStartDate: nil, practiceParticipation: nil, sportradarId: nil, fantasyDataId: nil, injuryStatus: nil, yahooId: nil, rotowireId: nil, rotoworldId: nil, espnId: nil, searchRank: nil),
		 PlayerModel(id: "1002", firstName: "Player", lastName: "Two", fullName: "Player Two", team: "ATL", position: "RB", age: 25, height: "5'11\"", weight: "220", status: "Active", college: "Another College", birthCity: nil, birthState: nil, birthCountry: "USA", birthDate: nil, yearsExp: 3, highSchool: nil, fantasyPositions: nil, metadata: nil, newsUpdated: nil, number: nil, depthChartPosition: nil, depthChartOrder: nil, rookieYear: nil, statsId: nil, searchLastName: nil, searchFirstName: nil, searchFullName: nil, hashtag: nil, injuryStartDate: nil, practiceParticipation: nil, sportradarId: nil, fantasyDataId: nil, injuryStatus: nil, yahooId: nil, rotowireId: nil, rotoworldId: nil, espnId: nil, searchRank: nil)
	  ]

	  return RosterDetailView(
		 managerID: "sample_owner_id",
		 managerName: "Sample Manager",
		 managerAvatarURL: URL(string: "https://sleepercdn.com/avatars/thumbs/sample_avatar.jpg"),
		 rosterViewModel: rosterViewModel)
   }
}
