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
			   RoundedRectangle(cornerRadius: 15)
				  .fill(LinearGradient(
					 gradient: Gradient(colors: [
						backgroundColor,
						backgroundColor.blended(withFraction: 0.55, of: .white)
					 ]),
					 startPoint: .top,
					 endPoint: .bottom
				  ))
				  .shadow(radius: 4)
			)
			.frame(maxWidth: .infinity)

			// Toggle to sort by draft order
			Toggle(isOn: $sortByDraftOrder) {
			   HStack {
				  Text("Sort by: ")
					 .foregroundColor(.gray)
				  Text("Draft Order")
					 .foregroundColor(.gpBlue)
			   }
			}
			.toggleStyle(SwitchToggleStyle(tint: .gpGreen))
			.padding()

			// Starters Section Header
			Text("Starters")
			   .font(.title)
			   .padding(.leading)
			   .foregroundColor(.gpGreen)

			// Starters Section
			let starters = sortByDraftOrder
			? rosterViewModel.sortStartersByDraftOrder(managerID: managerID)
			: rosterViewModel.managerStarters(managerID: managerID)

			RosterListView(players: starters, playerViewModel: PlayerViewModel(), draftViewModel: draftViewModel, showDraftDetails: true, backgroundColor: backgroundColor)
			   .padding(.horizontal)

			// Bench Section Header
			Spacer()
			Text("Bench")
			   .font(.title)
			   .padding(.leading)
			   .foregroundColor(.gpGreen)

			// Bench Players Section
			let allPlayers = rosterViewModel.rosters.first(where: { $0.ownerID == managerID })?.players ?? []
			let benchPlayers = sortByDraftOrder
			? rosterViewModel.sortBenchPlayersByDraftOrder(managerID: managerID, allPlayers: allPlayers, starters: starters)
			: allPlayers.filter { !starters.contains($0) }

			RosterListView(players: benchPlayers, playerViewModel: PlayerViewModel(), draftViewModel: draftViewModel, showDraftDetails: false, backgroundColor: backgroundColor)
			   .padding(.horizontal)
		 }
		 .padding(.horizontal)
	  }
	  .navigationTitle("Roster Detail")
   }
}
