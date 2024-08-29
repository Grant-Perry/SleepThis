import SwiftUI

struct PlayerSearchView: View {
   @StateObject private var playerViewModel = PlayerViewModel()
   @State private var playerLookup: String = ""
   @State private var sortOption: SortOption = .name

   enum SortOption: String, CaseIterable {
	  case name = "Player"
	  case team = "Team"
	  case position = "Position"
   }

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

			   // Sort Options Picker
			   Picker("Sort By", selection: $sortOption) {
				  ForEach(SortOption.allCases, id: \.self) { option in
					 Text(option.rawValue).tag(option)
				  }
			   }
			   .pickerStyle(SegmentedPickerStyle())
			   .padding(.horizontal)
			   .padding(.bottom)
			}

			// Scrollable List Section
			if !playerViewModel.players.isEmpty {
			   List(sortedPlayers) { player in
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
			Spacer()

			// Version Number in Safe Area
			Text("Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
			   .font(.system(size: 10))
			   .foregroundColor(.gray)
			   .padding(.bottom, 10)
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

   private var sortedPlayers: [PlayerModel] {
	  switch sortOption {
		 case .name:
			return playerViewModel.players.sorted {
			   ("\($0.lastName ?? "zzz") \($0.firstName ?? "zzz")").localizedStandardCompare("\($1.lastName ?? "zzz") \($1.firstName ?? "zzz")") == .orderedAscending
			}
		 case .team:
			return playerViewModel.players.sorted {
			   ($0.team ?? "zzz").localizedStandardCompare($1.team ?? "zzz") == .orderedAscending
			}
		 case .position:
			return playerViewModel.players.sorted {
			   ($0.position ?? "zzz").localizedStandardCompare($1.position ?? "zzz") == .orderedAscending
			}
	  }
   }
}
