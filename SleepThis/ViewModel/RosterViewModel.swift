import Foundation
import Combine

class RosterViewModel: ObservableObject {
   @Published var rosters: [RosterModel] = []
   @Published var selectedRosterSettings: RosterSettings?

   var leagueID = AppConstants.TwoBrothersID

   init(leagueID: String) {
	  self.leagueID = leagueID
	  fetchRoster()
   }

   func fetchRoster() {
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
				  // Debugging: Print the structure of firstRoster.settings
				  print("firstRoster.settings: \(firstRoster.settings)")

				  // Try to assign settings directly, ensuring the type matches
				  if let settings = firstRoster.settings as? RosterSettings {
					 self?.selectedRosterSettings = settings
					 print("selectedRosterSettings successfully assigned: \(settings)")
				  } else {
					 print("Error: settings cannot be cast to RosterSettings")
				  }
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
}
