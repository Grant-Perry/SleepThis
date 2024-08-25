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

			// Fixed header section
			VStack {
			   HStack {
				  if let cacheAge = playViewModel.cacheAgeDescription,
					 let cacheSize = playViewModel.cacheSize {
					 Text("\(cacheAge) ")
						.font(.footnote)
						.foregroundColor(.cyan)
					 +

					 Text("(\(cacheSize))")
						.font(.caption2)
						.foregroundColor(.pink)

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

			   // Search Section
			   HStack {
				  TextField("Enter Player Name or ID", text: $playerLookup)
					 .textFieldStyle(RoundedBorderTextFieldStyle())
					 .padding(.horizontal)

				  Button(action: {
					 playViewModel.fetchPlayers(playerLookup: playerLookup)
				  }) {
					 Text("Go")
				  }
				  .disabled(playerLookup.isEmpty)
				  .padding(.trailing)
			   }
			   .padding(.bottom)
			}

			// Scrollable List Section
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
		 .navigationTitle("Player Lookup")
		 .onAppear {
			playViewModel.loadCachedPlayers()
		 }
	  }
   }
}
