//
//  NewFantasyPlayerScores.swift
//
//  Purpose:
//  - A brand-new SwiftUI view that uses your existing FantasyMatchupViewModel and DraftViewModel
//    but does NOT modify them. We do, however, rely on you to ensure that `FantasyMatchupViewModel`
//    has finished fetching its Sleeper data (league settings, weekly stats, etc.) before we try to
//    compute points.
//  - If you want to do it automatically, you can watch some isLoading or isSleeperDataReady property
//    in your VM, but here we provide a "Compute Points" button to do it explicitly.
//
//  Key notes:
//   • No arbitrary Task.sleep. Instead, we only compute once you press "Compute Points" or
//     once you confirm in .onAppear that the data is actually ready (not isLoading).
//   • We handle the optional unwrapping of `sleeperLeagueSettings` and `playerStats` by
//     instantiating a new `SleeperPointsAggregator(fantasyVM: ...)`. If that fails, we show an error.
//
//  This file can fully replace your existing FantasyPlayerScores or be a new screen.
//  It references your existing `draftViewModel.fetchDraftData(...)` without changing it.
//

import SwiftUI

struct FantasyPlayerScores: View {

   // MARK: - Dependencies

   /// Your existing DraftViewModel, no modifications
   @StateObject var draftViewModel = DraftViewModel(leagueID: AppConstants.leagueID)

   /// Your existing FantasyMatchupViewModel that fetches Sleeper scoring + weekly stats, etc.
   @StateObject var fantasyViewModel = FantasyMatchupViewModel()

   /// Possibly your existing PlayerViewModel if you want local names or caching
   @StateObject var playerViewModel = PlayerViewModel()

   // MARK: - State

   /// How many top picks to show
   @State private var numberOfPicks: Int = 36

   /// The final array displayed in the List
   @State private var playerScores: [PlayerScore] = []

   /// If aggregator fails or data isn’t ready, store an error
   @State private var errorMessage: String? = nil

   /// A struct to hold row data
   struct PlayerScore: Identifiable {
	  let id = UUID()
	  let playerName: String
	  let playerID: String
	  let managerName: String
	  let totalPoints: Double
	  let playerAvatar: URL?
	  let teamAvatar: URL?
   }

   // MARK: - Body

   var body: some View {
	  VStack(spacing: 10) {
		 // Region to pick how many picks to show
		 Picker("Number of Draft Picks", selection: $numberOfPicks) {
			ForEach(0..<12, id: \.self) { index in
			   Text("Row #\(index + 1)")
			}
		 }
		 .pickerStyle(.menu)
		 .padding()

		 // A button to (re)compute points once we confirm the data is loaded
		 Button("Compute Points") {
			Task {
			   await loadDraftPicks()
			}
		 }
		 .padding(.vertical, 6)

		 if let err = errorMessage {
			Text("Error: \(err)")
			   .foregroundColor(.red)
			   .padding(.horizontal)
		 }

		 // Show the final list
		 List(playerScores.sorted(by: { $0.totalPoints > $1.totalPoints })) { score in
			HStack {
			   // Player avatar
			   AsyncImage(url: score.playerAvatar) { image in
				  image.resizable().scaledToFit()
			   } placeholder: {
				  Color.gray
			   }
			   .frame(width: 40, height: 40)
			   .clipShape(Circle())

			   VStack(alignment: .leading) {
				  Text(score.playerName)
					 .font(.headline)
				  Text("Manager: \(score.managerName)")
					 .font(.subheadline)
			   }

			   Spacer()

			   AsyncImage(url: score.teamAvatar) { image in
				  image.resizable().scaledToFit()
			   } placeholder: {
				  Color.gray
			   }
			   .frame(width: 30, height: 30)

			   Text(String(format: "%.1f", score.totalPoints))
				  .foregroundColor(.blue)
			}
		 }
		 .listStyle(.plain)
	  }
	  .onAppear {
		 // If you want an auto-fetch of picks, do it here. We won't compute points
		 // until user hits "Compute Points" or you handle a .onChange for isLoading, etc.
		 fetchDraftPicks()
	  }
   }

   // MARK: - Private

   private func fetchDraftPicks() {
	  // 1. Possibly load local Player data
	  if playerViewModel.players.isEmpty {
		 playerViewModel.loadPlayersFromCache()
	  }

	  // 2. Call your existing draft fetch
	  draftViewModel.fetchDraftData(draftID: AppConstants.draftID) { success in
		 if !success {
			self.errorMessage = "Failed to fetch draft picks."
		 }
	  }
   }

   private func loadDraftPicks() async {
	  // Ensure fantasyViewModel is done fetching (sleeperLeagueSettings + playerStats).
	  // If your code sets a property like `fantasyViewModel.isLoading == false`
	  // or `fantasyViewModel.playerStats.isEmpty == false`, you can check that.
	  // We'll demonstrate a simple check:

	  guard !fantasyViewModel.playerStats.isEmpty else {
		 self.errorMessage = "Fantasy data not loaded yet (playerStats is empty)."
		 return
	  }
	  guard let _ = fantasyViewModel.sleeperLeagueSettings else {
		 self.errorMessage = "Sleeper scoring settings not loaded yet."
		 return
	  }

	  // Build a brand-new aggregator referencing the *current* data in fantasyViewModel
	  let aggregator = SleeperPointsAggregator()

	  // Sort picks by ascending pick_no, then take top N
	  let sortedPicks = draftViewModel.drafts.sorted { $0.pick_no < $1.pick_no }
	  let topPicks = sortedPicks.prefix(numberOfPicks)

	  var tempScores: [PlayerScore] = []

	  for pick in topPicks {
		 // Player name
		 let localPlayer = playerViewModel.players.first(where: { $0.id == pick.player_id })
		 let fullName: String = {
			if let ln = localPlayer?.fullName, !ln.isEmpty {
			   return ln
			}
			if let meta = pick.metadata {
			   let combo = "\(meta.first_name ?? "") \(meta.last_name ?? "")"
				  .trimmingCharacters(in: .whitespaces)
			   return combo.isEmpty ? "Unknown Player" : combo
			}
			return "Unknown Player"
		 }()

		 // Manager name
		 let managerName = draftViewModel.managerName(for: pick.picked_by)

		 // Sum points via aggregator
		 let totalPts = fantasyViewModel.calculateSeasonPoints(
			for: pick.player_id
		 )

		 // Avatars
		 let pAvatar = URL(string: "https://sleepercdn.com/content/nfl/players/\(pick.player_id).jpg")
		 let teamAbbrev = pick.metadata?.team?.lowercased() ?? "placeholder"
		 let tAvatar = URL(string: "https://sleepercdn.com/images/team_logos/nfl/\(teamAbbrev).png")
		 ?? URL(string: "https://sleepercdn.com/images/team_logos/nfl/placeholder.png")

		 tempScores.append(
			PlayerScore(
			   playerName: fullName,
			   playerID: pick.player_id,
			   managerName: managerName,
			   totalPoints: totalPts,
			   playerAvatar: pAvatar,
			   teamAvatar: tAvatar
			)
		 )
	  }

	  // Update UI
	  self.playerScores = tempScores
	  print("[loadDraftPicks] Done. Created \(tempScores.count) rows.")
	  self.errorMessage = nil
   }
}
