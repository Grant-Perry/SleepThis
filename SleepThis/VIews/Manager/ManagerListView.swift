import SwiftUI

struct ManagerListView: View {
   // MARK: - Properties
   @StateObject var draftViewModel: DraftViewModel
   @StateObject var rosterViewModel: RosterViewModel
   @State private var leagueName: String = ""
   @State private var sortedManagerIDsState: [String] = []
   @State private var isLoading = true
   @State private var errorMessage: String?
   @State private var isRosterLoaded = false  // Add this

   // Your existing properties remain the same
   let leagueID: String
   let draftID: String
   let viewType: ManagerViewType
   let mgrColors: [Color] = [
	  .mBG1, .mBG2, .mBG3, .mBG4, .mBG5, .mBG6,
	  .mBG7, .mBG8, .mBG9, .mBG10, .mBG11, .mBG12
   ]

   // MARK: - Body
   var body: some View {
	  NavigationView {
		 Group {
			if isLoading {
			   ProgressView("Loading managers...")
				  .frame(maxWidth: .infinity, maxHeight: .infinity)
			} else if let error = errorMessage {
			   Text(error)
				  .foregroundColor(.red)
				  .frame(maxWidth: .infinity, maxHeight: .infinity)
			} else {
			   ScrollView {
				  VStack(alignment: .leading, spacing: 10) {
					 if !leagueName.isEmpty {
						Text(leagueName)
						   .frame(maxWidth: .infinity)
						   .lineLimit(1)
						   .minimumScaleFactor(0.5)
						   .font(.title)
						   .foregroundColor(.gpWhite)
						   .padding(.leading)
					 }

					 if !isRosterLoaded {
						ProgressView("Loading roster data...")
						   .frame(maxWidth: .infinity)
					 } else {
						LazyVStack(spacing: 8) {
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
							  .padding(.horizontal)
						   }
						}
						.padding(.vertical)
					 }
				  }
			   }
			}
		 }
		 .navigationTitle(viewType == .draft ? "Draft Managers" : "Roster Managers")
		 .navigationBarTitleDisplayMode(.inline)
	  }
	  .preferredColorScheme(.dark)
	  .onAppear {
		 isLoading = true
		 errorMessage = nil
		 isRosterLoaded = false

		 print("[ManagerListView] Starting data load for leagueID: \(leagueID)")

		 // First, fetch draft data
		 draftViewModel.fetchDraftData(draftID: draftID) { draftSuccess in
			guard draftSuccess else {
			   print("[ManagerListView] Failed to fetch draft data.")
			   DispatchQueue.main.async {
				  self.errorMessage = "Failed to load draft data."
				  self.isLoading = false
			   }
			   return
			}

			// With draft data loaded, we should have `groupedPicks` and manager IDs.
			self.draftViewModel.fetchAllManagerDetails { managerSuccess in
			   guard managerSuccess else {
				  print("[ManagerListView] Failed to fetch manager details.")
				  DispatchQueue.main.async {
					 self.errorMessage = "Failed to load manager details."
					 self.isLoading = false
				  }
				  return
			   }

			   print("[ManagerListView] Successfully fetched all manager details")
			   DispatchQueue.main.async {
				  self.sortedManagerIDsState = self.computeSortedManagerIDs()
			   }

			   // Now fetch roster data
			   self.rosterViewModel.fetchRoster {
				  print("[ManagerListView] Roster fetch completed. Count: \(self.rosterViewModel.rosters.count)")
				  DispatchQueue.main.async {
					 self.isRosterLoaded = true
					 self.isLoading = false
				  }
			   }
			}
		 }

		 // Fetch league name separately
		 let leagueVM = LeagueViewModel()
		 leagueVM.fetchLeague(leagueID: leagueID) { league in
			DispatchQueue.main.async {
			   if let league = league {
				  self.leagueName = league.name
				  print("[ManagerListView] League name set to: \(league.name)")
			   } else {
				  self.leagueName = "Unknown League"
				  print("[ManagerListView] Failed to fetch league name")
			   }
			}
		 }
	  }
   }

   // MARK: - Methods
   private func loadData() {
	  isLoading = true
	  errorMessage = nil
	  isRosterLoaded = false

	  print("[ManagerListView] Starting data load for leagueID: \(leagueID)")

	  // First, fetch draft details
	  draftViewModel.fetchAllManagerDetails { success in
		 if success {
			print("[ManagerListView] Successfully fetched all manager details")
			sortedManagerIDsState = computeSortedManagerIDs()

			// Then fetch roster data
			rosterViewModel.fetchRoster {
			   print("[ManagerListView] Roster fetch completed. Count: \(rosterViewModel.rosters.count)")
			   DispatchQueue.main.async {
				  isRosterLoaded = true
				  isLoading = false
			   }
			}
		 } else {
			print("[ManagerListView] Failed to fetch manager details")
			DispatchQueue.main.async {
			   errorMessage = "Failed to load manager data"
			   isLoading = false
			}
		 }
	  }

	  // Fetch league name
	  let leagueVM = LeagueViewModel()
	  leagueVM.fetchLeague(leagueID: leagueID) { league in
		 DispatchQueue.main.async {
			if let league = league {
			   self.leagueName = league.name
			   print("[ManagerListView] League name set to: \(league.name)")
			} else {
			   self.leagueName = "Unknown League"
			   print("[ManagerListView] Failed to fetch league name")
			}
		 }
	  }
   }
   private func computeSortedManagerIDs() -> [String] {
	  let keys = Array(draftViewModel.groupedPicks.keys)
	  return keys.sorted { key1, key2 in
		 let firstSlot = draftViewModel.groupedPicks[key1]?.first?.draft_slot ?? 0
		 let secondSlot = draftViewModel.groupedPicks[key2]?.first?.draft_slot ?? 0
		 return firstSlot < secondSlot
	  }
   }
}
