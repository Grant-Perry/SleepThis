import SwiftUI

struct PlayerSearchView: View {
   @ObservedObject private var viewModel = PlayerViewModel()
   @State private var playerLookup: String = ""

   var body: some View {
	  NavigationView {
		 VStack {
			if viewModel.isLoading {
			   ProgressView("LOADING DATA...")
				  .padding()
			}

			HStack {
			   if let cacheAge = viewModel.cacheAgeDescription,
					 let cacheSize = viewModel.cacheSize {
				  Text("\(cacheAge) \(cacheSize)")
					 .font(.caption)
			   }
			   Spacer()
			   Button(action: {
				  viewModel.reloadCache()
			   }) {
				  Image(systemName: "arrow.clockwise.circle.fill")
					 .font(.title2) // Adjusts the size of the image if needed
			   }
			}
			.padding()

			Form {
			   Section(header: Text("Search Player")) {
				  TextField("Enter Player Name or ID", text: $playerLookup)
					 .textFieldStyle(RoundedBorderTextFieldStyle())

				  Button(action: {
					 viewModel.fetchPlayer(playerLookup: playerLookup)
				  }) {
					 Text("Go")
				  }
				  .disabled(playerLookup.isEmpty)
			   }

			   if !viewModel.players.isEmpty {
				  List(viewModel.players) { player in
					 NavigationLink(destination: PlayerDetailView(player: player, viewModel: viewModel)) {
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
			   } else if let errorMessage = viewModel.errorMessage {
				  Text("Error: \(errorMessage)")
					 .foregroundColor(.red)
			   } else {
				  Text("No player data available.")
			   }
			}
		 }
		 .navigationTitle("Player Lookup")
	  }
   }
}


