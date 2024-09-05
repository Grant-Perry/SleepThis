import SwiftUI

struct DraftListView: View {
   @ObservedObject var draftViewModel = DraftViewModel()

   var body: some View {
	  NavigationView {
		 List {
			// Iterate over sorted manager IDs and group by manager
			ForEach(draftViewModel.groupedPicks.keys.sorted(), id: \.self) { managerID in
			   Section(header: Text(draftViewModel.managerName(for: managerID))) {
				  // Retrieve the picks for each manager
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
			// Pass the correct draftID when calling the fetch method
			draftViewModel.fetchDraftData(draftID: "your_draft_id_here")
		 }
	  }
   }
}
