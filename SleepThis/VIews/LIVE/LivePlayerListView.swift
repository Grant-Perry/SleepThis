import SwiftUI

struct LivePlayerListView: View {
   @StateObject private var viewModel = LivePlayerViewModel()

   var body: some View {
	  NavigationStack {
		 List(viewModel.players) { player in
			NavigationLink(destination: LivePlayerDetailView(player: player)) {
			   VStack(alignment: .leading) {
				  Text(player.playerPoolEntry.player.fullName)
					 .font(.headline)
				  Text("Score: \(player.playerPoolEntry.appliedStatTotal, specifier: "%.2f")")
					 .font(.subheadline)
			   }
			}
		 }
		 .navigationTitle("Fantasy Players")
		 .refreshable {
			viewModel.fetchESPNPlayerData()
		 }
	  }
   }
}
