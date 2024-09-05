import SwiftUI

struct DraftListView: View {
   @ObservedObject var draftViewModel = DraftViewModel()

   var body: some View {
	  NavigationView {
		 List {
			// Sort manager IDs and iterate over them
			ForEach(draftViewModel.groupedPicks.keys.sorted(), id: \.self) { managerID in
			   Section(header: Text(draftViewModel.managerName(for: managerID))) {
				  if let picks = draftViewModel.groupedPicks[managerID] {
					 ForEach(picks) { draft in
						NavigationLink(destination: DraftDetailView(draftPick: draft)) {
						   DraftRowView(draft: draft)
						}
					 }
				  }
			   }
			}
		 }
		 .navigationTitle("Draft Picks")
		 .onAppear {
			print("------------------------------------\n\(#file) \(#line):[DraftListView]: DraftListView appeared")
			// Make sure to pass the correct draftID
			draftViewModel.fetchDraftData(draftID: AppConstants.DraftID)
		 }
	  }
   }
}
