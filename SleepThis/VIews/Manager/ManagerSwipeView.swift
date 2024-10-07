import SwiftUI

struct ManagerSwipeView: View {
   var draftViewModel: DraftViewModel
   var rosterViewModel: RosterViewModel
   var playerViewModel: PlayerViewModel

   @State private var isDataLoaded = false

   var body: some View {
	  if isDataLoaded {
		 TabView {
			ForEach(rosterViewModel.rosters, id: \.ownerID) { roster in
			   let ownerIDString = String(describing: roster.ownerID)
			   if let managerDetails = draftViewModel.managerDetails[ownerIDString] {
				  VStack {
					 Text(managerDetails.name)
						.font(.largeTitle)
						.padding()

					 RosterDetailView(
						leagueID: rosterViewModel.leagueID,
						managerID: ownerIDString,
						managerName: managerDetails.name,
						managerAvatarURL: draftViewModel.managerAvatar(for: ownerIDString),
						draftViewModel: draftViewModel,
						rosterViewModel: rosterViewModel
					 )
				  }
				  .padding()
				  .tag(ownerIDString)
			   } else {
				  Text("Manager details not found for \(ownerIDString)")
			   }
			}
		 }
		 .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
	  } else {
		 Text("Loading managers and rosters...")
			.onAppear {
			   fetchData()
			}
	  }
   }

   func fetchData() {
	  var dataLoadedCount = 0
	  let totalDataTypes = 2

	  // Fetch draft details
	  draftViewModel.fetchDraftData(draftID: AppConstants.draftID) { success in
		 if success {
			// Now fetch manager details
			draftViewModel.fetchAllManagerDetails { success in
			   DispatchQueue.main.async {
				  dataLoadedCount += 1
				  if dataLoadedCount == totalDataTypes { checkDataLoaded() }
			   }
			}
		 } else {
			DispatchQueue.main.async {
			   dataLoadedCount += 1
			   if dataLoadedCount == totalDataTypes { checkDataLoaded() }
			}
		 }
	  }

	  // **Re-enable fetchRoster**
	  rosterViewModel.fetchRoster {
		 DispatchQueue.main.async {
			dataLoadedCount += 1
			if dataLoadedCount == totalDataTypes { checkDataLoaded() }
		 }
	  }

	  // **Re-enable loadPlayersFromCache**
	  playerViewModel.loadPlayersFromCache()
   }


   func checkDataLoaded() {
	  DispatchQueue.main.async {
		 print("[checkDataLoaded]: managerDetails.count = \(draftViewModel.managerDetails.count)")
		 print("[checkDataLoaded]: rosters.count = \(rosterViewModel.rosters.count)")
		 if !draftViewModel.managerDetails.isEmpty && !rosterViewModel.rosters.isEmpty {
			print("[checkDataLoaded]: Data is fully loaded.")
			isDataLoaded = true
		 } else {
			print("[checkDataLoaded]: Data is not fully loaded.")
		 }
	  }
   }
}
