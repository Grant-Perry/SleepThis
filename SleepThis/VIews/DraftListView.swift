import SwiftUI

struct DraftListView: View {
   let managerID: String
   @ObservedObject var draftViewModel: DraftViewModel

   var body: some View {
	  List {
		 if let picks = draftViewModel.groupedPicks[managerID] {
			ForEach(picks) { draft in
			   NavigationLink(destination: DraftDetailView(draftPick: draft)) {
				  DraftRowView(draft: draft)
			   }
			}
		 } else {
			Text("No picks available for this manager.")
		 }
	  }
	  .navigationBarTitleDisplayMode(.inline)
	  .toolbar {
		 ToolbarItem(placement: .principal) {
			Text("Picks for \(draftViewModel.managerName(for: managerID))")
			   .font(.callout)
			   .bold()
		 }
	  }
   }
}
