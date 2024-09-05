import Foundation
import Combine

class DraftViewModel: ObservableObject {
   @Published var drafts: [DraftModel] = []

   var groupedPicks: [String: [DraftModel]] {
	  let grouped = Dictionary(grouping: drafts) { $0.picked_by }
	  print("[groupedPicks]: Grouped picks by manager: \(grouped)")
	  return grouped
   }

   func managerName(for id: String) -> String {
	  // Debug print statement
	  print("[managerName]: Fetching name for manager ID: \(id)")
	  return "Manager \(id)" // Example placeholder
   }

   func fetchDraftData(draftID: String) {
	  print("----------------------\(#file) \(#line)\n[fetchDraftData]: Starting to fetch draft data for draft ID: \(draftID)")

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

		 // Log the raw JSON data for debugging
		 if let rawJSON = String(data: data, encoding: .utf8) {
//			print("[fetchDraftData]: Raw JSON response: \(rawJSON)")
		 }

		 do {
			let decodedData: [DraftModel] = try JSONDecoder().decode([DraftModel].self, from: data)
			DispatchQueue.main.async {
			   self.drafts = decodedData
			   print("[fetchDraftData]: Successfully fetched and decoded draft data")
			   print("[fetchDraftData]: \(self.drafts.count) picks loaded")

			   // Debugging each draft pick
			   for (index, draftPick) in self.drafts.prefix(10).enumerated() {
				  print("[fetchDraftData]: Pick \(index + 1): \(draftPick)")
			   }
			}
		 } catch let decodingError as DecodingError {
			switch decodingError {
			   case .typeMismatch(let type, let context):
				  print("[fetchDraftData]: Type mismatch for type \(type) - \(context.debugDescription)")
			   case .valueNotFound(let value, let context):
				  print("[fetchDraftData]: Value not found for \(value) - \(context.debugDescription)")
			   case .keyNotFound(let key, let context):
				  print("[fetchDraftData]: Key not found: \(key.stringValue) - \(context.debugDescription)")
			   case .dataCorrupted(let context):
				  print("[fetchDraftData]: Data corrupted - \(context.debugDescription)")
			   default:
				  print("[fetchDraftData]: Decoding error - \(decodingError.localizedDescription)")
			}
		 } catch {
			print("[fetchDraftData]: Failed to decode data - \(error.localizedDescription)")
		 }
	  }.resume()
   }


}
