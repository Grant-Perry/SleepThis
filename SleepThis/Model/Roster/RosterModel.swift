import Foundation

struct RosterModel: Identifiable, Codable {
   var id: Int { rosterID } 
   let coOwners: [String]?
   let keepers: [String]?
   let leagueID: String
   let metadata: [String: String]?
   let ownerID: String
   let playerMap: [String: String]?
   let players: [String]
   let rosterID: Int
   let settings: RosterSettings
   let starters: [String]
   let taxi: [String]?

   enum CodingKeys: String, CodingKey {
	  case coOwners = "co_owners"
	  case keepers
	  case leagueID = "league_id"
	  case metadata
	  case ownerID = "owner_id"
	  case playerMap = "player_map"
	  case players
	  case rosterID = "roster_id"
	  case settings
	  case starters
	  case taxi
   }
}

struct RosterSettings: Codable {
   let division: Int?
   let fpts: Int
   let fptsAgainst: Int?
   let losses: Int
   let ties: Int
   let totalMoves: Int
   let waiverBudgetUsed: Int
   let waiverPosition: Int
   let wins: Int

   enum CodingKeys: String, CodingKey {
	  case division
	  case fpts
	  case fptsAgainst = "fpts_against"
	  case losses
	  case ties
	  case totalMoves = "total_moves"
	  case waiverBudgetUsed = "waiver_budget_used"
	  case waiverPosition = "waiver_position"
	  case wins
   }
}
