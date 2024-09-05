import Foundation
import Combine

class DraftViewModel: ObservableObject {
   @Published var draftPicks: [DraftModel] = []
   @Published var isLoading = false
   @Published var errorMessage: String?
   @Published var drafts: [DraftModel] = []

   var groupedPicks: [String: [DraftModel]] {
	  Dictionary(grouping: drafts) { $0.picked_by }
   }

   func managerName(for id: String) -> String {
	  // Example placeholder; in real code, you'd map the id to a real manager name.
	  return "Manager \(id)"
   }


   func fetchDraftData(draftID: String) {
	  isLoading = true
	  errorMessage = nil

	  guard let url = URL(string: "https://api.sleeper.app/v1/draft/\(draftID)/picks") else {
		 self.errorMessage = "Invalid URL"
		 self.isLoading = false
		 return
	  }

	  URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
		 guard let self = self else { return }

		 if let error = error {
			DispatchQueue.main.async {
			   self.isLoading = false
			   self.errorMessage = error.localizedDescription
			}
			return
		 }

		 guard let data = data else {
			DispatchQueue.main.async {
			   self.isLoading = false
			   self.errorMessage = "No data received"
			}
			return
		 }

		 do {
			let decodedData: [DraftModel] = try JSONDecoder().decode([DraftModel].self, from: data)

			// No need for additional API calls, just use the metadata from the draft picks
			DispatchQueue.main.async {
			   self.draftPicks = decodedData
			   self.isLoading = false
			}

		 } catch {
			DispatchQueue.main.async {
			   self.isLoading = false
			   self.errorMessage = "Failed to decode data: \(error.localizedDescription)"
			}
		 }
	  }.resume()
   }
}
