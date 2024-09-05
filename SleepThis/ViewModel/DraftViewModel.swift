import Foundation
import Combine

class DraftViewModel: ObservableObject {
   @Published var draftPicks: [DraftModel] = []
   @Published var groupedPicks: [String: [DraftModel]] = [:] // Stored property, not computed

   func fetchDraftData(draftID: String) {
	  print("[fetchDraftData]: Starting to fetch draft data for draft ID: \(draftID)")

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
			   self.draftPicks = decodedData
			   self.groupedPicks = Dictionary(grouping: decodedData) { $0.picked_by }
			   print("[fetchDraftData]: Successfully fetched and grouped draft data")
			}
		 } catch {
			print("[fetchDraftData]: Failed to decode data - \(error.localizedDescription)")
		 }
	  }.resume()
   }

   func managerName(for id: String) -> String {
	  // Mock implementation or fetch real manager name based on id
	  return "Manager \(id)"
   }
}
