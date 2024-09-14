import Foundation

struct LeagueModel: Identifiable, Codable {
   let totalRosters: Int
   let status: String
   let sport: String
   let settings: LeagueSettings
   let seasonType: String
   let season: String
   let scoringSettings: [String: Double]
   let rosterPositions: [String]
   let previousLeagueID: String?
   let name: String
   let leagueID: String
   let draftID: String?
   let avatar: String?

   // Conform to Identifiable protocol
   var id: String { leagueID }

   enum CodingKeys: String, CodingKey {
	  case totalRosters = "total_rosters"
	  case status
	  case sport
	  case settings
	  case seasonType = "season_type"
	  case season
	  case scoringSettings = "scoring_settings"
	  case rosterPositions = "roster_positions"
	  case previousLeagueID = "previous_league_id"
	  case name
	  case leagueID = "league_id"
	  case draftID = "draft_id"
	  case avatar
   }
}

struct LeagueSettings: Codable {
   // Define the properties according to the settings object from the API response
   // Placeholder properties; replace with actual fields as needed
   let maxKeepers: Int?
   let draftRounds: Int?
   let playoffTeams: Int?
   // Add other properties as necessary

   enum CodingKeys: String, CodingKey {
	  case maxKeepers = "max_keepers"
	  case draftRounds = "draft_rounds"
	  case playoffTeams = "playoff_teams"
	  // Add other coding keys as necessary
   }
}
