//import SwiftUI
//
//struct DraftView: View {
//   @ObservedObject var draftViewModel = DraftViewModel()
//
//   var body: some View {
//	  NavigationView {
//		 VStack {
//			if draftViewModel.isLoading {
//			   ProgressView("Loading Draft Data...")
//			} else if draftViewModel.draftPicks.isEmpty {
//			   Text("No Draft Data Available")
//			} else {
//			   List(draftViewModel.draftPicks, id: \.pickNo) { pick in
//				  NavigationLink(destination: DraftDetailView(draftPick: pick)) {
//					 DraftRowView(draftPick: pick)  // Ensure this is recognized here
//				  }
//			   }
//			}
//		 }
//		 .onAppear {
//			draftViewModel.fetchDraftData()
//		 }
//		 .navigationTitle("Draft Picks")
//	  }
//   }
//}
