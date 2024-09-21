import SwiftUI

struct PlayerSearchView: View {
   @StateObject private var playerViewModel = PlayerViewModel()
   @State private var playerLookup: String = ""
   @State private var sortOption: SortOption = .name
   @State private var positionFilter: PositionFilter = .qb
   @State private var showInactivePlayersOnly = false

   enum SortOption: String, CaseIterable {
	  case name = "Player"
	  case team = "Team"
	  case position = "Position"
	  case inactive = "Inactive" // Added new case for status sorting
   }

   enum PositionFilter: String, CaseIterable {
	  case qb = "QB"
	  case rb = "RB"
	  case wr = "WR"
	  case k = "K"
	  case dst = "DST"
	  case te = "TE"
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
						.foregroundColor(.gpBlue)
					 +
					 Text("(\(cacheSize))")
						.font(.caption2)
						.foregroundColor(.gpGreen)
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
					 Image(systemName: "plus.magnifyingglass")
				  }
				  .disabled(playerLookup.isEmpty)
				  .padding(.trailing)
			   }

			   // Position Filter Picker
			   Picker("Filter By Position", selection: $positionFilter) {
				  ForEach(PositionFilter.allCases, id: \.self) { option in
					 Text(option.rawValue).tag(option)
				  }
			   }
			   .pickerStyle(SegmentedPickerStyle())
			   .padding(.horizontal)

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
			   List(filteredSortedPlayers) { player in
				  NavigationLink(destination: PlayerDetailView(player: player,
															   playerViewModel: playerViewModel,
															   round: 909,
															   pickNo: 909)) {
					 HStack {
						// Display player thumbnail
						if let url = URL(string: "https://sleepercdn.com/content/nfl/players/\(player.id).jpg") {
						   AsyncImage(url: url) { image in
							  image.resizable()
								 .aspectRatio(contentMode: .fill)
								 .frame(width: 150, height: 150)
								 .isOnIR(player.injuryStatus ?? "", hXw: 150)
						   } placeholder: {
							  Image(systemName: "person.crop.circle.fill")
								 .resizable()
								 .frame(width: 50, height: 50)
						   }
						}

						VStack(alignment: .leading) {
						   Text("\(player.firstName ?? "Unknown") \(player.lastName ?? "Unknown")")
							  .font(.headline)
						   VStack {
							  Text("Team: \(player.team ?? "Unknown")")
							  Text("Position: \(player.position ?? "Unknown")\(player.depthChartOrder ?? 0)")
//							  Text("Depth: #\(player.depthChartOrder ?? 0)")
							  if player.status?.lowercased() != "active" {
								 Text(" status: ")
									.foregroundColor(.gpWhite)
									+ Text("\(player.status ?? "Unknown")")
									.font(.caption2)
									.foregroundColor(player.injuryStatus == "IR" ? Color.red : Color.gpWhite)


								 Text("\(player.injuryStatus ?? "Unknown")")
									.font(.caption)
									.foregroundColor(.gpRed)
									.bold()
//								 Text("\(player.injuryStartDate ?? "Unknown")")
//									.font(.caption)


							  }

						   }
						   .font(.caption)
						   .padding(.leading, 1)
						}
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
			Text("Version: \(AppConstants.getVersion())")
			   .font(.system(size: AppConstants.verSize))
			   .foregroundColor(AppConstants.verColor)
//
//			Text(" - \(URL(fileURLWithPath: #file).deletingLastPathComponent().lastPathComponent)")
//			   .font(.footnote)
//			   .foregroundColor(.white)
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
	  .preferredColorScheme(.dark)
   }

   private var filteredSortedPlayers: [PlayerModel] {
	  var filteredPlayers: [PlayerModel] = playerViewModel.players.filter { player in
		 guard let position = player.position else { return false }
		 return ["QB", "RB", "WR", "TE", "K", "DST"].contains(position)
	  }

	  // Filter players based on the selected position
	  if positionFilter != .te {
		 filteredPlayers = filteredPlayers.filter { $0.position == positionFilter.rawValue }
	  }

	  // Check if the sortOption is 'inactive' to filter inactive players only
	  if sortOption == .inactive {
		 filteredPlayers = filteredPlayers.filter { $0.status?.lowercased() == "inactive" }
	  }

	  return filteredPlayers.sorted { player1, player2 in
		 let team1 = player1.team ?? ""
		 let team2 = player2.team ?? ""

		 let depthOrder1 = player1.depthChartOrder ?? Int.max
		 let depthOrder2 = player2.depthChartOrder ?? Int.max

		 // Sort by valid teams first
		 if team1.isEmpty != team2.isEmpty {
			return !team1.isEmpty
		 }

		 // Then sort by depth chart order within the position
		 if depthOrder1 != depthOrder2 {
			return depthOrder1 < depthOrder2
		 }

		 // Finally, sort by the chosen sort option
		 switch sortOption {
			case .name:
			   let name1 = "\(player1.lastName ?? "zzz") \(player1.firstName ?? "zzz")"
			   let name2 = "\(player2.lastName ?? "zzz") \(player2.firstName ?? "zzz")"
			   return name1.localizedStandardCompare(name2) == .orderedAscending
			case .team:
			   return team1.localizedStandardCompare(team2) == .orderedAscending
			case .position:
			   return (player1.position ?? "zzz") < (player2.position ?? "zzz")
			case .inactive:
			   let status1 = player1.status ?? "active"
			   let status2 = player2.status ?? "active"
			   return status1.localizedStandardCompare(status2) == .orderedAscending
		 }
	  }
   }

}
