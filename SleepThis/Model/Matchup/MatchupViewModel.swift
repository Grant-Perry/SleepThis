import SwiftUI
import Foundation
import Combine

class MatchupViewModel: ObservableObject {
   @Published var matchups: [MatchupModel] = []
   @Published var isLoading = false
   @Published var errorMessage: String?

   func fetchMatchups(leagueID: String, week: Int) {
	  print("[fetchMatchups:] Fetching matchups for leagueID: \(leagueID), week: \(week)")
	  isLoading = true
	  errorMessage = nil

	  let urlString = "https://api.sleeper.app/v1/league/\(leagueID)/matchups/\(week)"

	  guard let url = URL(string: urlString) else {
		 self.errorMessage = "Invalid URL"
		 isLoading = false
		 print("[fetchMatchups:] Invalid URL: \(urlString)")
		 return
	  }

	  URLSession.shared.dataTask(with: url) { data, response, error in
		 DispatchQueue.main.async {
			self.isLoading = false

			if let error = error {
			   self.errorMessage = error.localizedDescription
			   print("[fetchMatchups:] Network error: \(error.localizedDescription)")
			   return
			}

			guard let data = data else {
			   self.errorMessage = "No data received"
			   print("[fetchMatchups:] No data received from network")
			   return
			}

			do {
			   print("[fetchMatchups:] Attempting to decode matchup data...")
			   let matchups = try JSONDecoder().decode([MatchupModel].self, from: data)
			   self.matchups = matchups
			   print("[fetchMatchups:] Matchups successfully fetched.")
			} catch {
			   self.errorMessage = "Failed to decode matchups data: \(error)"
			   print("Decoding error: \(error.localizedDescription)\n\(String(describing: self.errorMessage))")
			}
		 }
	  }.resume()
   }

   func fetchMatchupsLegacy(leagueID: String, week: Int) {
	  isLoading = true
	  errorMessage = nil

	  let urlString = "https://api.sleeper.app/v1/league/\(leagueID)/matchups/\(week)"

	  guard let url = URL(string: urlString) else {
		 self.errorMessage = "Invalid URL"
		 isLoading = false
		 return
	  }

	  URLSession.shared.dataTask(with: url) { data, response, error in
		 DispatchQueue.main.async {
			self.isLoading = false

			if let error = error {
			   self.errorMessage = error.localizedDescription
			   return
			}

			guard let data = data else {
			   self.errorMessage = "No data received"
			   return
			}

			do {
			   let matchups = try JSONDecoder().decode([MatchupModel].self, from: data)
			   self.matchups = matchups
			} catch {
			   self.errorMessage = "Failed to decode matchups data: \(error)"
			}
		 }
	  }.resume()
   }
}
