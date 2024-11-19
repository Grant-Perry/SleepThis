import PythonKit
import SwiftUI

struct ESPNTools {
   /// Fetches all leagues that a given manager ID is part of.
   /// - Parameter managerID: The unique ID of the manager whose leagues you want to fetch.
   /// - Returns: An array of league IDs the manager is part of.
   static func fetchLeaguesForManager(managerID: String) -> [Int] {
	  // Hardcoded SWID and ESPN_S2 values from AppConstants
	  let swid = "{\(AppConstants.ESPNLeagueID)}"
	  let espnS2 = "\(AppConstants.ESPN_S2)"

	  // Import Python modules
	  let espnApi = Python.import("espn_api.football")

	  // Initialize the League object
	  let League = espnApi.League

	  // Fetch all available leagues
	  let leagueInstance = League(league_id: Python.None, year: Python.None, espn_s2: espnS2, swid: swid)
	  let leagues = leagueInstance.get_all_leagues()

	  // Prepare result array for league IDs
	  var leagueIDs: [Int] = []

	  // Iterate through leagues and check if the manager ID is part of the league
	  for league in leagues {
		 // Check if the manager is part of this league
		 let teams = league.teams
		 for team in teams {
			// Extract and compare the manager ID
			if let teamManagerID = String(team.owner_id), teamManagerID == managerID {
			   // Extract and append league ID
			   if let leagueID = Int(league.league_id.description) {
				  leagueIDs.append(leagueID)
			   }
			   break // No need to check other teams in this league
			}
		 }
	  }

	  return leagueIDs
   }
}
