import SwiftUI

struct RosterListView: View {
   @ObservedObject var rosterViewModel = RosterViewModel(leagueID: AppConstants.TwoBrothersID)
   let draftViewModel = DraftViewModel()
   let pastelColors: [Color] = [
	  .init(red: 0.8, green: 0.9, blue: 1.0),
	  .init(red: 0.9, green: 1.0, blue: 0.8),
	  .init(red: 1.0, green: 0.8, blue: 0.9),
	  .init(red: 0.9, green: 0.8, blue: 1.0),
	  .init(red: 1.0, green: 1.0, blue: 0.8)
   ]

   var body: some View {
	  NavigationView {
		 List {
			ForEach(rosterViewModel.rosters, id: \.ownerID) { roster in
			   let managerIndex = rosterViewModel.rosters.firstIndex(where: { $0.ownerID == roster.ownerID }) ?? 0
			   let backgroundColor = pastelColors[managerIndex % pastelColors.count]

			   NavigationLink(destination: RosterDetailView(managerID: roster.ownerID, rosterViewModel: rosterViewModel)) {
				  RosterRowView(roster: roster, draftViewModel: draftViewModel, backgroundColor: backgroundColor)
			   }
			}
		 }
		 .onAppear {
			rosterViewModel.fetchRoster()
			draftViewModel.fetchAllManagerDetails()  // Fetch all manager details
		 }
		 .navigationTitle("Rosters")
	  }
   }
}
