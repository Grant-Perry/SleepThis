import Foundation
import SwiftUI
import Combine

class RosterViewModel: ObservableObject {
   @Published var rosters: [RosterModel] = []
   @Published var selectedRosterSettings: RosterSettings?
   var draftViewModel: DraftViewModel

   var leagueID = AppConstants.leagueID // TwoBrothersID

   init(leagueID: String, draftViewModel: DraftViewModel) {
	  self.leagueID = leagueID
	  self.draftViewModel = draftViewModel
	  fetchRoster()
   }

   func fetchRoster() {
	  guard !leagueID.isEmpty else { return }
	  
	  guard let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)/rosters") else {
		 print("[RosterViewModel] Invalid URL.")
		 return
	  }

	  URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
		 if let error = error {
			print("[RosterViewModel] Error fetching rosters: \(error)")
			return
		 }
		 guard let data = data else {
			print("[RosterViewModel] No data returned.")
			return
		 }
		 do {
			let decoder = JSONDecoder()
			let decodedRosters = try decoder.decode([RosterModel].self, from: data)

			DispatchQueue.main.async {
			   self?.rosters = decodedRosters
			   if let firstRoster = decodedRosters.first {
				  print("DP - firstRoster.settings: \(firstRoster.settings)")

				  // Assign settings directly, ensuring the type matches
				  self?.selectedRosterSettings = firstRoster.settings
				  print("DP - selectedRosterSettings successfully assigned: \(firstRoster.settings)")
			   }
			}
		 } catch {
			print("[RosterViewModel] Failed to decode rosters: \(error)")
		 }
	  }.resume()
   }

   func getManagerSettings(managerID: String) -> RosterSettings? {
	  return rosters.first(where: { $0.ownerID == managerID })?.settings
   }

   func managerStarters(managerID: String) -> [String] {
	  return rosters.first(where: { $0.ownerID == managerID })?.starters ?? []
   }

   func sortStartersByDraftOrder(managerID: String) -> [String] {
	  let starters = managerStarters(managerID: managerID)
	  return starters.sorted { player1, player2 in
		 let draft1 = draftViewModel.getDraftDetails(for: player1)
		 let draft2 = draftViewModel.getDraftDetails(for: player2)
		 if let draft1 = draft1, let draft2 = draft2 {
			return (draft1.round, draft1.pick_no) < (draft2.round, draft2.pick_no)
		 } else {
			return false
		 }
	  }
   }

   func sortBenchPlayersByDraftOrder(managerID: String, allPlayers: [String], starters: [String]) -> [String] {
	  return allPlayers.filter { !starters.contains($0) }.sorted { player1, player2 in
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
		 print("DP - Draft Details: \(draftDetails)\nManagerID: \(managerID)\nPlayerID: \(playerID)\n----------------------------\n ")
		 return draftViewModel.getManagerColor(for: managerID)
	  } else {
		 print("DP - Player \(playerID) was not drafted.")
		 // If the player was not drafted, return .gpBlueDarkL
		 return .gpUndrafted // RIGHT HERE
	  }
   }
}
