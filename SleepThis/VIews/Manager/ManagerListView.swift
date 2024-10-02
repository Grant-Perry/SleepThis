import SwiftUI

struct ManagerListView: View {
   @StateObject var draftViewModel: DraftViewModel
   @StateObject var rosterViewModel: RosterViewModel
   @State private var leagueName: String = ""
   @State private var sortedManagerIDsState: [String] = []

   let leagueID: String
   let draftID: String
   let viewType: ManagerViewType
   let mgrColors: [Color] = [
	  .mBG1, .mBG2, .mBG3, .mBG4, .mBG5, .mBG6,
	  .mBG7, .mBG8, .mBG9, .mBG10, .mBG11, .mBG12
   ]

   var body: some View {
	  NavigationView {
		 ScrollView {
			VStack(alignment: .leading) {
			   // Display league name at the top
			   Text(leagueName)
				  .frame(maxWidth: .infinity)
				  .lineLimit(1)
				  .minimumScaleFactor(0.5)
				  .font(.title)
				  .foregroundColor(.gpWhite)
				  .padding(.leading)

			   LazyVStack(spacing: 0) {
				  ForEach(Array(sortedManagerIDsState.enumerated()), id: \.offset) { index, managerID in
					 let backgroundColor = mgrColors[index % mgrColors.count]

					 ManagerRowView(
						managerID: managerID,
						leagueID: leagueID,
						draftViewModel: draftViewModel,
						rosterViewModel: rosterViewModel,
						thisBackgroundColor: backgroundColor,
						viewType: viewType
					 )
					 .padding(.horizontal, 0)
				  }
			   }
			}
		 }
		 .navigationTitle(viewType == .draft ? "Draft Managers" : "Roster Managers")
		 .onAppear {
			draftViewModel.fetchAllManagerDetails { success in
			   if success {
				  print("Successfully fetched all manager details.")
				  // Compute sortedManagerIDsState here
				  sortedManagerIDsState = computeSortedManagerIDs()
			   } else {
				  print("Failed to fetch some manager details.")
			   }
			}

			rosterViewModel.fetchRoster()

			// Fetch the league name using leagueID
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
	  .preferredColorScheme(.dark)
   }

   func computeSortedManagerIDs() -> [String] {
	  let keys = Array(draftViewModel.groupedPicks.keys)
	  let sortedKeys = keys.sorted { key1, key2 in
		 let firstSlot = draftViewModel.groupedPicks[key1]?.first?.draft_slot ?? 0
		 let secondSlot = draftViewModel.groupedPicks[key2]?.first?.draft_slot ?? 0
		 return firstSlot < secondSlot
	  }
	  return sortedKeys
   }
}
