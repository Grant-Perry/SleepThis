import SwiftUI

struct RosterDetailView: View {
   let managerID: String
   let managerName: String
   let managerAvatarURL: URL?
   @ObservedObject var rosterViewModel: RosterViewModel
   @ObservedObject var draftViewModel: DraftViewModel
   let backgroundColor: Color
   @State private var sortByDraftOrder = false
   var playerSize = 50.0

   var body: some View {
	  ScrollView {
		 VStack(alignment: .leading, spacing: 10) {
			// Manager info
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
			   Text(managerName)
				  .font(.title)
			   Spacer()
			}
			.padding(.leading)
			.background(
			   RoundedRectangle(cornerRadius: 15)  // Rounded corners
				  .fill(LinearGradient(
					 gradient: Gradient(colors: [
						backgroundColor,
						backgroundColor.blended(withFraction: 0.55, of: .white)  // 55% blend with white
					 ]),
					 startPoint: .top,
					 endPoint: .bottom
				  ))


				  .shadow(radius: 4)
			)			.frame(maxWidth: .infinity)

			// Metrics Section
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
					 ManagerSettingsRow(label: "Budget:", value: "$\(100 - settings.waiverBudgetUsed)")
					 ManagerSettingsRow(label: "Spent:", value: "$\(settings.waiverBudgetUsed)")
					 ManagerSettingsRow(label: "Moves:", value: "\(settings.totalMoves)")
					 ManagerSettingsRow(label: "", value: "") // Empty to fill the space
				  }
			   }
			   .padding(.horizontal)
			   .padding(.top, 16)
			}

			// Toggle to sort by draft order
			HStack {
			   Toggle(isOn: $sortByDraftOrder) {
				  Spacer()
				  HStack {
					 Text("Sort by: ")
						.foregroundColor(.gray)
					 +
					 Text(" Draft Order")
						.foregroundStyle(Color.gpBlue)
				  }
				  .font(.system(size: 25))
				  .padding(.trailing, -50)
			   }
			   .toggleStyle(SwitchToggleStyle(tint: .gpGreen))
			   .padding(.trailing, 85)
			   .font(.system(size: 25))
			   .scaleEffect(0.5)
			}
			.padding()

			// Starters Section Header
			Text("Starters")
			   .font(.title)
			   .padding(.leading)
			   .foregroundColor(.gpGreen)

			let starters = sortByDraftOrder
			? rosterViewModel.sortStartersByDraftOrder(managerID: managerID)
			: rosterViewModel.managerStarters(managerID: managerID)

			ForEach(starters, id: \.self) { playerID in
			   HStack {
				  StarterListView(starters: [playerID], playerViewModel: PlayerViewModel())
				  if let draftDetails = draftViewModel.getDraftDetails(for: playerID) {
					 Text("\(draftDetails.round).\(draftDetails.pick_no)")
						.font(.footnote)
						.foregroundColor(.gray)
						.padding(.top, 10)
				  }
			   }
			   .frame(maxWidth: .infinity)
			   .background(
				  RoundedRectangle(cornerRadius: 15)  // Rounded corners
					 .fill(LinearGradient(
						gradient: Gradient(colors: [
						   backgroundColor,
						   backgroundColor.blended(withFraction: 0.55, of: .white)  // 55% blend with white
						]),
						startPoint: .top,
						endPoint: .bottom
					 ))


					 .shadow(radius: 4)
			   )
			}
			.padding(.horizontal)

			// Bench Players Section
			Text("Bench")
			   .font(.title)
			   .padding(.leading)
			   .foregroundColor(.gpGreen)

			let allPlayers = rosterViewModel.rosters.first(where: { $0.ownerID == managerID })?.players ?? []
			let benchPlayers = sortByDraftOrder
			? rosterViewModel.sortBenchPlayersByDraftOrder(managerID: managerID, allPlayers: allPlayers, starters: starters)
			: allPlayers.filter { !starters.contains($0) }

			BenchView(benchPlayers: benchPlayers, playerViewModel: PlayerViewModel(), draftViewModel: draftViewModel)
			   .padding(.horizontal)
		 }
		 .padding(.horizontal)
	  }
	  .navigationTitle("Roster Detail")
   }
}
