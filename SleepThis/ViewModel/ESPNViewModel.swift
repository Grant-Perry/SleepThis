import Foundation

class ESPNViewModel: ObservableObject {
   @Published var espnPlayerData: ESPNPlayerModel?
   @Published var isLoading = false
   @Published var errorMessage: String?

   func fetchESPNPlayerData(for player: PlayerModel) {
	  isLoading = true
	  errorMessage = nil

	  let urlString = "https://site.api.espn.com/apis/common/v3/sports/football/nfl/players/\(player.id)"

	  guard let url = URL(string: urlString) else {
		 self.errorMessage = "Invalid URL"
		 self.isLoading = false
		 return
	  }

	  URLSession.shared.dataTask(with: url) { data, response, error in
		 DispatchQueue.main.async {
			self.isLoading = false

			if let error = error {
			   self.errorMessage = error.localizedDescription
			   print("[ESPNViewModel:fetchESPNPlayerData] Error: \(error.localizedDescription)")
			   return
			}

			guard let data = data else {
			   self.errorMessage = "No data received"
			   print("[ESPNViewModel:fetchESPNPlayerData] No data received")
			   return
			}

			do {
			   let decodedPlayer = try JSONDecoder().decode(ESPNPlayerModel.self, from: data)
			   self.espnPlayerData = decodedPlayer
			   print("[ESPNViewModel:fetchESPNPlayerData] Successfully decoded ESPN player data: \(decodedPlayer)")
			} catch {
			   self.errorMessage = "Failed to decode ESPN player data: \(error)"
			   print("[ESPNViewModel:fetchESPNPlayerData] Decoding error: \(error)")
			}
		 }
	  }.resume()
   }
}
