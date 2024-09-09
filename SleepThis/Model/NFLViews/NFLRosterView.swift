import SwiftUI

struct NFLRosterView: View {
   @StateObject var viewModel = NFLRosterViewModel()

   var body: some View {
	  NavigationStack {
		 List(viewModel.players) { player in
			NavigationLink(destination: NFLPlayerDetailView(player: player)) {
			   VStack(alignment: .leading) {
				  Text(player.fullName)
					 .font(.headline)
				  Text(player.teamName)
					 .font(.subheadline)
					 .foregroundColor(.secondary)
			   }
			}
		 }
		 .navigationTitle("NFL Roster")
	  }
	  .onAppear {
		 print("[NFLRosterView:onAppear] Loaded \(viewModel.players.count) players.")
	  }
   }
}
