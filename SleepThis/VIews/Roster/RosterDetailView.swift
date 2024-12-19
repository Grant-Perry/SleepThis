import SwiftUI

struct RosterDetailView: View {
   @StateObject private var playerViewModel = PlayerViewModel()
   @ObservedObject var rosterViewModel: RosterViewModel
   @ObservedObject var draftViewModel: DraftViewModel
   let leagueID: String
   let managerID: String
   let managerName: String
   let managerAvatarURL: URL?
//   var draftViewModel: DraftViewModel
//   var rosterViewModel: RosterViewModel
//   @StateObject var playerViewModel = PlayerViewModel()
   @State private var sortByDraftOrder = false
   @State private var leagueName: String = ""
   @State private var isLoading = true
   @State private var errorMessage: String?
   var playerSize = 50.0

   init(
	  leagueID: String,
	  managerID: String,
	  managerName: String,
	  managerAvatarURL: URL?,
	  draftViewModel: DraftViewModel,
	  rosterViewModel: RosterViewModel
   ) {
	  self.leagueID = leagueID
	  self.managerID = managerID
	  self.managerName = managerName
	  self.managerAvatarURL = managerAvatarURL
	  self.draftViewModel = draftViewModel
	  self.rosterViewModel = rosterViewModel
   }

   var body: some View {
	  VStack {
		 if isLoading {
			ProgressView("Loading roster...")
			   .frame(maxWidth: .infinity, maxHeight: .infinity)
		 } else if let error = errorMessage {
			Text(error)
			   .foregroundColor(.red)
			   .frame(maxWidth: .infinity, maxHeight: .infinity)
		 } else {
			ScrollView {
			   VStack(alignment: .leading, spacing: 10) {
				  // League Name at the top
				  Text(leagueName)
					 .font(.title)
					 .foregroundColor(.gpWhite)
					 .padding(.leading)

				  // Manager Info
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
					 ZStack {
						// Bokeh image in the background
						Image("bokeh")
						   .resizable()
						   .scaledToFill()
						   .opacity(0.8)
						   .saturation(0.5)
						   .clipShape(RoundedRectangle(cornerRadius: 15))

						// The gradient and shadow over the image
						RoundedRectangle(cornerRadius: 15)
						   .fill(
							  LinearGradient(
								 gradient: Gradient(colors: [
									draftViewModel.getManagerColor(for: managerID),
									.clear
								 ]),
								 startPoint: .top,
								 endPoint: .bottom
							  )
						   )
						   .shadow(radius: 4)
					 }
				  )
				  .clipShape(RoundedRectangle(cornerRadius: 15))
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
					 .frame(maxWidth: .infinity)
					 .lineLimit(1)
					 .minimumScaleFactor(0.5)
					 .scaledToFit()

				  // Starters Section
				  let starters = sortByDraftOrder
				  ? rosterViewModel.sortStartersByDraftOrder(managerID: managerID)
				  : rosterViewModel.managerStarters(managerID: managerID)

				  RosterDetailListView(
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
					 .frame(maxWidth: .infinity)
					 .lineLimit(1)
					 .minimumScaleFactor(0.5)
					 .scaledToFit()

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
		 }
	  }
	  .navigationBarTitleDisplayMode(.inline)
	  .onAppear {
		 isLoading = true  // Start loading
		 let leagueVM = LeagueViewModel()
		 leagueVM.fetchLeague(leagueID: leagueID) { league in
			DispatchQueue.main.async {
			   self.leagueName = league?.name ?? "Unknown League"
			   // After fetching league name, now fetch the roster
			   self.rosterViewModel.fetchRoster {
				  // IMPORTANT: Ensure UI updates happen on the main thread
				  DispatchQueue.main.async {
					 self.isLoading = false  // Done loading the roster
				  }
			   }
			}
		 }
	  }

   }
}
