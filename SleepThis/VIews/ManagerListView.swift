import SwiftUI

struct ManagerListView: View {
   @ObservedObject var draftViewModel: DraftViewModel
   let viewType: ManagerViewType

   let pastelColors: [Color] = [
	  .init(red: 0.8, green: 0.9, blue: 1.0),
	  .init(red: 0.9, green: 1.0, blue: 0.8),
	  .init(red: 1.0, green: 0.8, blue: 0.9),
	  .init(red: 0.9, green: 0.8, blue: 1.0),
	  .init(red: 1.0, green: 1.0, blue: 0.8)
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
		 ScrollView {  // Replaced List with ScrollView to customize row alignment
			VStack(spacing: 0) {  // No spacing between rows
			   ForEach(sortedManagerIDs, id: \.self) { managerID in
				  let managerIndex = sortedManagerIDs.firstIndex(of: managerID) ?? 0
				  let backgroundColor = pastelColors[managerIndex % pastelColors.count]

				  ManagerRowView(managerID: managerID,
								 draftViewModel: draftViewModel,
								 backgroundColor: backgroundColor,
								 viewType: viewType)
					 .padding(.horizontal, 0)  // Ensure the row spans edge to edge
			   }
			}
		 }
		 .navigationTitle(viewType == .draft ? "Draft Managers" : "Roster Managers")
		 .onAppear {
			draftViewModel.fetchDraftData(draftID: AppConstants.DraftID)
		 }
	  }
   }
}
