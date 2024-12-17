import Foundation
import SwiftUI
import Combine
import Observation

//@Observable
class RosterViewModel: ObservableObject {
   @Published var rosters: [RosterModel] = []
   @Published var selectedRosterSettings: RosterSettings?
   @Published var isLoading = false
   @Published var errorMessage: String?

   var draftViewModel: DraftViewModel
   var leagueID = AppConstants.leagueID


   init(leagueID: String, draftViewModel: DraftViewModel) {
	  self.leagueID = leagueID
	  self.draftViewModel = draftViewModel
	  print("[RosterViewModel] Initialized with leagueID: \(leagueID)")
   }

   func fetchRoster(completion: (() -> Void)? = nil) {
	  print("[RosterViewModel] Starting roster fetch for leagueID: \(leagueID)")
	  isLoading = true
	  errorMessage = nil

	  guard !leagueID.isEmpty else {
		 print("[RosterViewModel] Empty leagueID")
		 isLoading = false
		 errorMessage = "Invalid league ID"
		 completion?()
		 return
	  }

	  guard let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)/rosters") else {
		 print("[RosterViewModel] Invalid URL")
		 isLoading = false
		 errorMessage = "Invalid URL"
		 completion?()
		 return
	  }

	  print("[RosterViewModel] Fetching from URL: \(url.absoluteString)")

	  URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
		 guard let self = self else { completion?(); return }

		 DispatchQueue.main.async {
			if let error = error {
			   print("[RosterViewModel] Network error: \(error.localizedDescription)")
			   self.errorMessage = error.localizedDescription
			   self.isLoading = false
			   completion?()
			   return
			}

			if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
			   self.errorMessage = "Server error: \(httpResponse.statusCode)"
			   self.isLoading = false
			   completion?()
			   return
			}

			guard let data = data else {
			   print("[RosterViewModel] No data returned")
			   self.errorMessage = "No data received"
			   self.isLoading = false
			   completion?()
			   return
			}

			do {
			   let decodedRosters = try JSONDecoder().decode([RosterModel].self, from: data)
			   print("[RosterViewModel] Successfully decoded \(decodedRosters.count) rosters")
			   self.rosters = decodedRosters
			   if let firstRoster = decodedRosters.first {
				  print("[RosterViewModel] First roster settings: \(firstRoster.settings)")
				  self.selectedRosterSettings = firstRoster.settings
			   }
			   self.isLoading = false
			   completion?()
			} catch {
			   print("[RosterViewModel] Decoding error: \(error.localizedDescription)")
			   self.errorMessage = "Failed to decode roster data"
			   self.isLoading = false
			   completion?()
			}
		 }
	  }.resume()
   }


   func getManagerSettings(managerID: String) -> RosterSettings? {
	  return rosters.first(where: { $0.ownerID == managerID })?.settings
   }
   func sortStartersByDraftOrder(managerID: String) -> [String] {
	  print("[RosterViewModel] Sorting starters by draft order for manager: \(managerID)")
	  let starters = managerStarters(managerID: managerID)
	  let sortedStarters = starters.sorted { player1, player2 in
		 let draft1 = draftViewModel.getDraftDetails(for: player1)
		 let draft2 = draftViewModel.getDraftDetails(for: player2)
		 if let draft1 = draft1, let draft2 = draft2 {
			return (draft1.round, draft1.pick_no) < (draft2.round, draft2.pick_no)
		 } else {
			return false
		 }
	  }
	  print("[RosterViewModel] Sorted starters count: \(sortedStarters.count)")
	  return sortedStarters
   }

   func managerStarters(managerID: String) -> [String] {
	  print("[RosterViewModel] Getting starters for managerID: \(managerID)")
	  let roster = rosters.first(where: { $0.ownerID == managerID })
	  print("[RosterViewModel] Found roster: \(roster != nil)")
	  let starters = roster?.starters ?? []
	  print("[RosterViewModel] Number of starters found: \(starters.count)")
	  return starters
   }

   func sortBenchPlayersByDraftOrder(managerID: String, allPlayers: [String], starters: [String]) -> [String] {
	  print("[RosterViewModel] Sorting bench players. All players count: \(allPlayers.count), Starters count: \(starters.count)")
	  let benchPlayers = allPlayers.filter { !starters.contains($0) }
	  print("[RosterViewModel] Bench players count: \(benchPlayers.count)")
	  return benchPlayers.sorted { player1, player2 in
		 let draft1 = draftViewModel.getDraftDetails(for: player1)
		 let draft2 = draftViewModel.getDraftDetails(for: player2)
		 if let draft1 = draft1, let draft2 = draft2 {
			return (draft1.round, draft1.pick_no) < (draft2.round, draft2.pick_no)
		 } else {
			return false
		 }
	  }
   }

   func getBackgroundColor(for playerID: String, draftViewModel: DraftViewModel) -> Color {
	  if let draftDetails = draftViewModel.getDraftDetails(for: playerID) {
		 let managerID = draftDetails.picked_by
		 print("[RosterViewModel] Player \(playerID) was drafted by \(managerID)")
		 return draftViewModel.getManagerColor(for: managerID)
	  } else {
		 print("[RosterViewModel] Player \(playerID) was not drafted")
		 return .gpUndrafted
	  }
   }
}
