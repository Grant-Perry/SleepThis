import Foundation
import Combine
import SwiftUI
import Observation

@Observable

class DraftViewModel: ObservableObject {
   var drafts: [DraftModel] = []
   var groupedPicks: [String: [DraftModel]] = [:]
   var managerDetails: [String: (name: String, avatar: String?)] = [:]
   var managerIDToColor: [String: Color] = [:]
   var managers: [ManagerModel] = []
   var leagueID: String = ""
   private var cancellables = Set<AnyCancellable>()

   init(leagueID: String) {
	  self.leagueID = leagueID
   }

   func fetchDraftData(draftID: String, completion: @escaping (Bool) -> Void) {
	  guard !leagueID.isEmpty else {
		 completion(false)
		 return
	  }

	  guard let url = URL(string: "https://api.sleeper.app/v1/draft/\(draftID)/picks") else {
		 print("[fetchDraftData]: Invalid URL")
		 completion(false)
		 return
	  }

	  URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
		 guard let self = self else {
			completion(false)
			return
		 }

		 if let error = error {
			print("[fetchDraftData]: Error fetching draft data - \(error.localizedDescription)")
			completion(false)
			return
		 }

		 guard let data = data else {
			print("[fetchDraftData]: No data received")
			completion(false)
			return
		 }

		 // Log the raw JSON response for debugging
		 if let jsonString = String(data: data, encoding: .utf8) {
			print("[fetchDraftData]: Raw JSON Response: \(jsonString)")
		 }

		 do {
			// Decode the response to DraftModel
			let decodedData: [DraftModel] = try JSONDecoder().decode([DraftModel].self, from: data)
			DispatchQueue.main.async {
			   self.drafts = decodedData
			   self.groupedPicks = Dictionary(grouping: decodedData) { $0.picked_by }
			   self.assignManagerColors()  // Assign colors to managers based on draft order

			   print("[fetchDraftData]: Successfully fetched and decoded draft data")
			   completion(true)  // Indicate successful completion
			}
		 } catch {
			print("[fetchDraftData]: Failed to decode data - \(error.localizedDescription)")
			completion(false)  // Indicate failure
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
	  return managerIDToColor[managerID] ?? .gpUndrafted
   }

   // Fetch manager details from the Sleeper API with a completion handler
   func fetchManagerDetails(managerID: String, completion: @escaping (Bool) -> Void) {
	  guard let url = URL(string: "https://api.sleeper.app/v1/user/\(managerID)") else {
		 print("[fetchManagerDetails]: Invalid manager URL for ID: \(managerID)")
		 completion(false) // Call completion with `false` indicating failure.
		 return
	  }

	  print("[fetchManagerDetails]: Fetching manager details for ID: \(managerID)")

	  URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
		 guard let self = self else {
			completion(false)
			return
		 }

		 if let data = data {
			do {
			   let json = try JSONDecoder().decode(ManagerModel.self, from: data)
			   DispatchQueue.main.async {
				  self.managerDetails[managerID] = (name: json.display_name ?? json.username, avatar: json.avatar)
				  print("[fetchManagerDetails]: Successfully fetched manager details for ID: \(managerID)")
				  completion(true) // Call completion with `true` indicating success.
			   }
			} catch {
			   print("[fetchManagerDetails]: Error decoding manager data for \(managerID): \(error)")
			   completion(false)
			}
		 } else {
			print("[fetchManagerDetails]: No data received for manager ID: \(managerID)")
			completion(false)
		 }
	  }.resume()
   }



   // Fetch all manager details with a completion handler
   func fetchAllManagerDetails(completion: @escaping (Bool) -> Void) {
	  let managerIDs = Array(groupedPicks.keys)
	  var fetchCount = 0

	  for managerID in managerIDs {
		 fetchManagerDetails(managerID: managerID) { success in
			fetchCount += 1
			if !success {
			   print("[fetchAllManagerDetails]: Failed to fetch manager details for ID: \(managerID)")
			}
			// When all manager details have been fetched, call the completion handler
			if fetchCount == managerIDs.count {
			   completion(true) // All tasks finished successfully
			}
		 }
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
	  return drafts.first(where: { $0.player_id == playerID })
		 .map { ($0.round, $0.pick_no, $0.picked_by) }
   }

   // Get Player Status
   func getPlayerStatus(for playerID: String, playerViewModel: PlayerViewModel) -> String? {
	  let thisBack = playerViewModel.players.first(where: { $0.id == playerID })?.status
	  print("Player Status: \(String(describing: thisBack))")
	  return thisBack
   }
}
