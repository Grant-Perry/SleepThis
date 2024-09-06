import Foundation
import Combine

class DraftViewModel: ObservableObject {
   @Published var drafts: [DraftModel] = []
   @Published var groupedPicks: [String: [DraftModel]] = [:]
   @Published var managerDetails: [String: (name: String, avatar: String?)] = [:] // Store manager details

   func fetchDraftData(draftID: String) {
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
			   self.fetchAllManagerDetails() // Fetch manager details after decoding draft data
			   print("[fetchDraftData]: Successfully fetched and decoded draft data")
			}
		 } catch {
			print("[fetchDraftData]: Failed to decode data - \(error.localizedDescription)")
		 }
	  }.resume()
   }

   // Function to fetch manager details from the Sleeper API
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
}
