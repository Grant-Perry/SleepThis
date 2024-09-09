//import SwiftUI
//
//struct RosterListView: View {
//   @ObservedObject var rosterViewModel = RosterViewModel(leagueID: AppConstants.TwoBrothersID)
//   let draftViewModel = DraftViewModel()  // Use this to fetch manager names and avatars
//
//   var body: some View {
//	  NavigationView {
//		 List {
//			ForEach(rosterViewModel.rosters, id: \.ownerID) { roster in
//			   let managerID = roster.ownerID
//
//			   NavigationLink(destination: RosterDetailView(managerID: roster.ownerID, rosterViewModel: rosterViewModel)) {
//				  HStack {
//					 if let avatarURL = draftViewModel.managerAvatar(for: managerID) {
//						AsyncImage(url: avatarURL) { image in
//						   image.resizable()
//							  .aspectRatio(contentMode: .fill)
//							  .frame(width: 50, height: 50)
//							  .clipShape(Circle())
//						} placeholder: {
//						   Image(systemName: "person.crop.circle")
//							  .resizable()
//							  .frame(width: 50, height: 50)
//						}
//					 }
//
//					 VStack(alignment: .leading) {
//						Text(draftViewModel.managerName(for: managerID))  // Fetch manager name
//						   .font(.headline)
//						Text("Owner ID: \(roster.ownerID)")
//						   .font(.subheadline)
//					 }
//				  }
//			   }
//			}
//		 }
//		 .onAppear {
//			rosterViewModel.fetchRoster()
//			draftViewModel.fetchAllManagerDetails()  // Fetch all manager details
//		 }
//		 .navigationTitle("Rosters")
//	  }
//   }
//}
