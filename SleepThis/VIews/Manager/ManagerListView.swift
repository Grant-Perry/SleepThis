import SwiftUI

struct ManagerListView: View {
   @ObservedObject var draftViewModel: DraftViewModel
   @State private var isLoading = true // Add loading state

   let viewType: ManagerViewType
   let mgrColors: [Color] = [.mBG1,.mBG2,.mBG3,.mBG4,.mBG5, .mBG6,
							 .mBG7, .mBG8, .mBG9, .mBG10, .mBG11, .mBG12]

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
			// Display loading view while data is loading
			Text("Loading \(viewType == .draft ? "Draft" : "Roster") Managers...")
			   .font(.headline)
			   .foregroundColor(.gray)
			   .onAppear {
				  draftViewModel.fetchDraftData(draftID: AppConstants.draftID)
				  isLoading = false // Set loading to false after fetching data
			   }
		 } else {
			ScrollView {  // Display content when loading is complete
			   LazyVStack(spacing: 0) {
				  ForEach(Array(sortedManagerIDs.enumerated()), id: \.element) { index, managerID in
					 let backgroundColor = mgrColors[index % mgrColors.count]
					 ManagerRowView(managerID: managerID,
									draftViewModel: draftViewModel,
									thisBackgroundColor: backgroundColor,
									viewType: viewType)
					 .padding(.horizontal, 0)
				  }

			   }
			}
			.navigationTitle(viewType == .draft ? "Draft Managers" : "Roster Managers")


		 }
	  }
	  .preferredColorScheme(.dark)
   }
}
