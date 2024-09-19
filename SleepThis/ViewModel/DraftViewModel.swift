import Foundation
import Combine
import SwiftUI

class DraftViewModel: ObservableObject {
   @Published var drafts: [DraftModel] = []
   @Published var groupedPicks: [String: [DraftModel]] = [:]
   @Published var managerDetails: [String: (name: String, avatar: String?)] = [:]
   @Published var managerIDToColor: [String: Color] = [:]
   @Published var managers: [ManagerModel] = []
   var leagueID: String = ""
   private var cancellables = Set<AnyCancellable>()

   init(leagueID: String) {
	  self.leagueID = leagueID
   }

   func fetchDraftData(draftID: String) {
	  guard !leagueID.isEmpty else { return }
	  guard let url = URL(string: "https://api.sleeper.app/v1/draft/\(draftID)/picks") else {
		 print("[fetchDraftData]: Invalid URL")
		 return
	  }

	  URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
		 guard let self = self else { return }

		 if let error = error {
			print("[fetchDraftData]: Error fetching draft data - \(error.localizedDescription)")
			return
		 }

		 guard let data = data else {
			print("[fetchDraftData]: No data received")
			return
		 }

		 do {
			let decodedData: [DraftModel] = try JSONDecoder().decode([DraftModel].self, from: data)
			DispatchQueue.main.async {
			   self.drafts = decodedData
			   self.groupedPicks = Dictionary(grouping: decodedData) { $0.picked_by }
			   self.assignManagerColors()  // Assign colors after grouping picks
			   self.fetchAllManagerDetails()
			   print("[fetchDraftData]: Successfully fetched and decoded draft data")
			}
		 } catch {
			print("[fetchDraftData]: Failed to decode data - \(error.localizedDescription)")
		 }
	  }.resume()
   }

   // Assign colors to each manager based on their draft slot order
   func assignManagerColors() {
	  let sortedManagerIDs = groupedPicks.keys.sorted {
		 let firstSlot = groupedPicks[$0]?.first?.draft_slot ?? 0
		 let secondSlot = groupedPicks[$1]?.first?.draft_slot ?? 0
		 return firstSlot < secondSlot
	  }

	  let mgrColors: [Color] = [
		 .mBG1, .mBG2, .mBG3, .mBG4, .mBG5, .mBG6,
		 .mBG7, .mBG8, .mBG9, .mBG10, .mBG11, .mBG12
	  ]

	  for (index, managerID) in sortedManagerIDs.enumerated() {
		 let color = mgrColors[index % mgrColors.count]
		 managerIDToColor[managerID] = color
	  }
   }

   // Get the color assigned to a manager
   func getManagerColor(for managerID: String) -> Color {
	  return managerIDToColor[managerID] ?? .gpUndrafted // .gpGray // THIS is it too
   }

   // Fetch manager details from the Sleeper API
   func fetchManagerDetails(managerID: String) {
	  guard let url = URL(string: "https://api.sleeper.app/v1/user/\(managerID)") else {
		 print("[fetchManagerDetails]: Invalid manager URL for ID: \(managerID)")
		 return
	  }

	  print("[fetchManagerDetails]: Fetching manager details for ID: \(managerID)")

	  URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
		 guard let self = self else { return }

		 if let data = data {
			do {
			   let json = try JSONDecoder().decode(ManagerModel.self, from: data)
			   DispatchQueue.main.async {
				  self.managerDetails[managerID] = (name: json.display_name ?? json.username, avatar: json.avatar)
				  print("[fetchManagerDetails]: Successfully fetched manager details for ID: \(managerID)")
			   }
			} catch {
			   print("[fetchManagerDetails]: Error decoding manager data for \(managerID): \(error)")
			}
		 } else {
			print("[fetchManagerDetails]: No data received for manager ID: \(managerID)")
		 }
	  }.resume()
   }

   // Fetch all manager details
   func fetchAllManagerDetails() {
	  guard !leagueID.isEmpty else { return }

	  for managerID in groupedPicks.keys {
		 print("Fetching manager details for managerID: \(managerID) [fetchAllManagerDetails]")
		 fetchManagerDetails(managerID: managerID)
	  }
   }

   // Get manager name
   func managerName(for managerID: String) -> String {
	  return managerDetails[managerID]?.name ?? "Unknown Manager"
   }

   // Get manager avatar URL
   func managerAvatar(for managerID: String) -> URL? {
	  guard let avatar = managerDetails[managerID]?.avatar else { return nil }
	  return URL(string: "https://sleepercdn.com/avatars/thumbs/\(avatar)")
   }

   // Get draft details for a specific player, including who picked them
   func getDraftDetails(for playerID: String) -> (round: Int, pick_no: Int, picked_by: String)? {
	  // Look for the player in the drafts
	  return drafts.first(where: { $0.player_id == playerID })
		 .map { ($0.round, $0.pick_no, $0.picked_by) }
   }


   // New Method to Get Player Status
   func getPlayerStatus(for playerID: String, playerViewModel: PlayerViewModel) -> String? {
	  return playerViewModel.players.first(where: { $0.id == playerID })?.status
   }


}
