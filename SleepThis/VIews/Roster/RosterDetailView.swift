import SwiftUI

struct RosterDetailView: View {
   let managerID: String
   let managerName: String
   let managerAvatarURL: URL?
   @ObservedObject var rosterViewModel: RosterViewModel
   @ObservedObject var draftViewModel: DraftViewModel
   @ObservedObject var playerViewModel = PlayerViewModel()
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
						draftViewModel.getManagerColor(for: managerID),
						draftViewModel.getManagerColor(for: managerID).blended(withFraction: 0.55, of: .white)
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

			RosterListView(
			   players: starters,
			   playerViewModel: playerViewModel,
			   draftViewModel: draftViewModel,
			   rosterViewModel: rosterViewModel,
			   showDraftDetails: true
			)
			.padding(.horizontal)

			// Bench Section Header
			Text("Bench")
			   .font(.title)
			   .padding(.leading)
			   .foregroundColor(.gpGreen)

			// Bench Players Section
			let allPlayers = rosterViewModel.rosters.first(where: { $0.ownerID == managerID })?.players ?? []
			let benchPlayers = sortByDraftOrder
			? rosterViewModel.sortBenchPlayersByDraftOrder(managerID: managerID, allPlayers: allPlayers, starters: starters)
			: allPlayers.filter { !starters.contains($0) }

			RosterListView(
			   players: benchPlayers,
			   playerViewModel: playerViewModel,
			   draftViewModel: draftViewModel,
			   rosterViewModel: rosterViewModel,
			   showDraftDetails: false
			)
			.padding(.horizontal)
		 }
		 .padding(.horizontal)
	  }
	  .navigationTitle("Roster Detail")
	  .onAppear {
		 playerViewModel.loadPlayersFromCache()
	  }
   }
}
