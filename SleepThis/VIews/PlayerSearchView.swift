import SwiftUI

struct PlayerSearchView: View {
   @ObservedObject private var playViewModel = PlayerViewModel()
   @State private var playerLookup: String = ""

   var body: some View {
	  NavigationView {
		 VStack {
			if playViewModel.isLoading {
			   ProgressView("LOADING DATA...")
				  .padding()
			}

			HStack {
			   if let cacheAge = playViewModel.cacheAgeDescription,
				  let cacheSize = playViewModel.cacheSize {
				  Text("\(cacheAge) \(cacheSize)")
					 .font(.caption)
			   }
			   Spacer()
			   Button(action: {
				  playViewModel.reloadCache()
			   }) {
				  Image(systemName: "arrow.clockwise.circle.fill")
					 .font(.title2)
			   }
			}
			.padding()

			Form {
			   Section(header: Text("Search Player")) {
				  TextField("Enter Player Name or ID", text: $playerLookup)
					 .textFieldStyle(RoundedBorderTextFieldStyle())

				  Button(action: {
					 playViewModel.fetchPlayers(playerLookup: playerLookup)
				  }) {
					 Text("Go")
				  }
				  .disabled(playerLookup.isEmpty)
			   }

			   if !playViewModel.players.isEmpty {
				  List(playViewModel.players) { player in
					 NavigationLink(destination: PlayerDetailView(player: player, playerViewModel: playViewModel)) {
						VStack(alignment: .leading) {
						   Text("\(player.fullName ?? "Unknown"): ")
							  .font(.headline) +
						   Text("\(player.id)")
							  .font(.footnote)
							  .foregroundColor(.gray)

						   Text("Team: \(player.team ?? "Unknown")")
						   Text("Position: \(player.position ?? "Unknown")")
						}
					 }
				  }
			   } else if let errorMessage = playViewModel.errorMessage {
				  Text("Error: \(errorMessage)")
					 .foregroundColor(.red)
			   } else {
				  Text("No player data available.")
			   }
			}
		 }
		 .navigationTitle("Player Lookup")
		 .onAppear {
			playViewModel.loadCachedPlayers()
		 }
	  }
   }
}
