import SwiftUI

struct ManagerListView: View {
   @ObservedObject var draftViewModel: DraftViewModel
   @ObservedObject var rosterViewModel: RosterViewModel
   @State private var isLoading = true
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
		 if isLoading {
			Text("Loading \(viewType == .draft ? "Draft" : "Roster") Managers...")
			   .font(.headline)
			   .foregroundColor(.gray)
			
			   .onAppear {
				  draftViewModel.fetchDraftData(draftID: draftID)
				  draftViewModel.fetchAllManagerDetails()
				  rosterViewModel.fetchRoster()

				  // Fetch the league name using leagueID
				  let leagueVM = LeagueViewModel()
				  leagueVM.fetchLeague(leagueID: leagueID) { league in
					 if let league = league {
						self.leagueName = league.name
					 } else {
						self.leagueName = "Unknown League"
					 }
					 isLoading = false
				  }
			   }
		 } else {
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
				  Text(leagueID)
					 .font(.footnote)

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
		 }
	  }
	  .preferredColorScheme(.dark)
   }
}
