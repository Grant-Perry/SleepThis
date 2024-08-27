import SwiftUI

struct PlayerSearchView: View {
   @StateObject private var playerViewModel = PlayerViewModel()
   @State private var playerLookup: String = ""

   var body: some View {
	  NavigationView {
		 VStack {
			if playerViewModel.isLoading {
			   ProgressView("LOADING DATA...")
				  .padding()
			}

			// Fixed header section
			VStack {
			   HStack {
				  if let cacheAge = playerViewModel.cacheAgeDescription,
					 let cacheSize = playerViewModel.cacheSize {
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
					 print("[PlayerSearchView:reloadCache] Reloading cache...")
					 playerViewModel.reloadCache()
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
					 print("[PlayerSearchView:searchPlayer] Searching player with lookup: \(playerLookup)")
					 playerViewModel.fetchPlayersByLookup(playerLookup: playerLookup)
				  }) {
					 Text("Go")
				  }
				  .disabled(playerLookup.isEmpty)
				  .padding(.trailing)
			   }
			   .padding(.bottom)
			}

			// Scrollable List Section
			if !playerViewModel.players.isEmpty {
			   List(playerViewModel.players) { player in
				  NavigationLink(destination: PlayerDetailView(player: player, playerViewModel: playerViewModel)) {
					 VStack(alignment: .leading) {
						Text("\(player.firstName ?? "Unknown") \(player.lastName ?? "Unknown")")
						   .font(.headline)
						Text("Team: \(player.team ?? "Unknown")")
						Text("Position: \(player.position ?? "Unknown")")
					 }
				  }
			   }
			} else if let errorMessage = playerViewModel.errorMessage {
			   Text("Error: \(errorMessage)")
				  .foregroundColor(.red)
			} else {
			   Text("No player data available.")
			}
		 }
		 .navigationTitle("Player Lookup")
		 .onAppear {
			print("[PlayerSearchView:onAppear] Loading cache or fetching players if needed.")
			playerViewModel.loadPlayersFromCache()
			if playerViewModel.players.isEmpty {
			   playerViewModel.fetchAllPlayers()
			}
		 }
	  }
   }
}
