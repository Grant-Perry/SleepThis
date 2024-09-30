import SwiftUI

struct ManagerListView: View {
   @StateObject var draftViewModel: DraftViewModel
   @StateObject var rosterViewModel: RosterViewModel
   @State private var leagueName: String = ""

   let leagueID: String
   let draftID: String
   let viewType: ManagerViewType
   let mgrColors: [Color] = [
	  .mBG1, .mBG2, .mBG3, .mBG4, .mBG5, .mBG6,
	  .mBG7, .mBG8, .mBG9, .mBG10, .mBG11, .mBG12
   ]

   var sortedManagerIDs: [String] {
	  draftViewModel.groupedPicks.keys.sorted {
		 let firstSlot = draftViewModel.groupedPicks[$0]?.first?.draft_slot ?? 0
		 let secondSlot = draftViewModel.groupedPicks[$1]?.first?.draft_slot ?? 0
		 return firstSlot < secondSlot
	  }
   }

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
				  ForEach(Array(sortedManagerIDs.enumerated()), id: \.offset) { index, managerID in
					 let backgroundColor = mgrColors[index % mgrColors.count]

					 ManagerRowView(
						managerID: managerID,
						leagueID: leagueID,
						draftViewModel: draftViewModel,
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
}
