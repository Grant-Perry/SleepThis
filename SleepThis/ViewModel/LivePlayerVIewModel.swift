import SwiftUI
import Combine

class LivePlayerViewModel: ObservableObject {
   @Published var players: [Player] = []
   @Published var isLoading: Bool = false
   @Published var errorMessage: String?

   // Remove cache entirely
   func loadData() {
	  isLoading = true
	  errorMessage = nil
	  fetchDataFromNetwork()  // Always fetch from network
   }

   private func fetchDataFromNetwork() {
	  let leagueID = AppConstants.ESPNLeagueID
	  guard let url = URL(string: "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/2024/segments/0/leagues/\(leagueID)?view=mMatchupScore&view=mLiveScoring&view=mRoster") else {
		 print("Invalid URL")
		 DispatchQueue.main.async {
			self.isLoading = false
			self.errorMessage = "Invalid URL"
		 }
		 return
	  }

	  var request = URLRequest(url: url)
	  request.httpMethod = "GET"
	  let cookieString = "SWID=\(AppConstants.SWID); espn_s2=\(AppConstants.ESPN_S2)"
	  request.setValue(cookieString, forHTTPHeaderField: "Cookie")
	  request.setValue("application/json", forHTTPHeaderField: "Accept")

	  let session = URLSession(configuration: .default)
	  let task = session.dataTask(with: request) { data, response, error in
		 if let httpResponse = response as? HTTPURLResponse {
			print("HTTP Status Code: \(httpResponse.statusCode)")
			if httpResponse.statusCode != 200 {
			   DispatchQueue.main.async {
				  self.isLoading = false
				  self.errorMessage = "Server returned status code \(httpResponse.statusCode)"
			   }
			   return
			}
		 }

		 if let error = error {
			print("Error fetching data: \(error.localizedDescription)")
			DispatchQueue.main.async {
			   self.isLoading = false
			   self.errorMessage = error.localizedDescription
			}
			return
		 }

		 guard let data = data else {
			print("No data received")
			DispatchQueue.main.async {
			   self.isLoading = false
			   self.errorMessage = "No data received"
			}
			return
		 }

		 do {
			let decoder = JSONDecoder()
			decoder.keyDecodingStrategy = .convertFromSnakeCase
			let livePlayerModel = try decoder.decode(LivePlayerModel.self, from: data)
			print("Decoded LivePlayerModel: \(livePlayerModel)")

			DispatchQueue.main.async {
			   self.processLivePlayerModel(livePlayerModel)
			   self.isLoading = false // Reset isLoading here
			   print("Final state - isLoading: \(self.isLoading), players count: \(self.players.count)")
			}
		 } catch {
			print("Error decoding data: \(error.localizedDescription)")
			DispatchQueue.main.async {
			   self.isLoading = false
			   self.errorMessage = "Error decoding data: \(error.localizedDescription)"
			}
		 }
	  }
	  task.resume()
   }


   private func processLivePlayerModel(_ livePlayerModel: LivePlayerModel) {
	  var allPlayers: [Player] = []
	  if let teams = livePlayerModel.teams {
		 for team in teams {
			print("Processing team ID: \(team.id ?? 0)")

			if let rosterEntries = team.roster?.entries {
			   print("Team \(team.id ?? 0) has \(rosterEntries.count) roster entries")

			   for rosterEntry in rosterEntries {
				  // Access player through nested structure
				  if let player = rosterEntry.playerPoolEntry?.player {
					 print("Found player: \(player.fullName ?? "Unknown Player")")
					 allPlayers.append(player)
				  } else {
					 print("No player found in roster entry")
				  }
			   }
			} else {
			   print("No roster entries for team ID \(team.id ?? 0)")
			}
		 }
	  }
	  print("Total players loaded: \(allPlayers.count)")
	  self.players = allPlayers
   }
}
