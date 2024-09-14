import SwiftUI

struct RosterDetailView: View {
   let leagueID: String
   let managerID: String
   let managerName: String
   let managerAvatarURL: URL?
   @ObservedObject var draftViewModel: DraftViewModel
   @StateObject var rosterViewModel: RosterViewModel
   @StateObject var playerViewModel = PlayerViewModel()
   @State private var sortByDraftOrder = false
   @State private var leagueName: String = ""
   var playerSize = 50.0

   init(leagueID: String, managerID: String, managerName: String, managerAvatarURL: URL?, draftViewModel: DraftViewModel) {
	  self.leagueID = leagueID
	  self.managerID = managerID
	  self.managerName = managerName
	  self.managerAvatarURL = managerAvatarURL
	  self.draftViewModel = draftViewModel
	  _rosterViewModel = StateObject(wrappedValue: RosterViewModel(leagueID: leagueID, draftViewModel: draftViewModel))
   }

   var body: some View {
	  ScrollView {
		 VStack(alignment: .leading, spacing: 10) {
			// League Name at the top
			Text(leagueName)
			   .font(.title)
			   .foregroundColor(.gpWhite)
			   .padding(.leading)

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
				  .foregroundColor(.gpBlueDark)
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
				  Text("\(sortByDraftOrder ? "Draft" : "Roster") Order")
					 .foregroundColor(.gpBlue)
			   }
			   .font(.title)
			}
			.toggleStyle(SwitchToggleStyle(tint: .gpGreen))
			.scaleEffect(0.6)
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

			RosterDetailListView(
			   players: starters,
			   playerViewModel: playerViewModel,
			   draftViewModel: draftViewModel,
			   rosterViewModel: rosterViewModel,
			   showDraftDetails: true)
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

			RosterDetailListView(
			   players: benchPlayers,
			   playerViewModel: playerViewModel,
			   draftViewModel: draftViewModel,
			   rosterViewModel: rosterViewModel,
			   showDraftDetails: true
			)
			.padding(.horizontal)
		 }
		 .padding(.horizontal)
	  }
	  .navigationTitle("Roster Detail")
	  .onAppear {
		 playerViewModel.loadPlayersFromCache()

		 // Fetch the league name
		 let leagueVM = LeagueViewModel()
		 leagueVM.fetchLeague(leagueID: leagueID) { league in
			if let league = league {
			   self.leagueName = league.name
			} else {
			   self.leagueName = "Unknown League"
			}
		 }
	  }
   }
}
