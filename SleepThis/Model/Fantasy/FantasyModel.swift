import Foundation

enum Fantasy {

   struct Model: Codable {
	  let schedule: [Matchup]
   }

   struct Matchup: Codable {
	  let home: Team
	  let away: Team
	  let id: Int
	  let matchupPeriodId: Int
	  let winner: String?
   }

   struct Team: Codable {
	  let teamId: Int
	  let teamName: String // Add the team name from the JSON 'team' key
	  let totalPoints: Double?
	  let players: [Player]?
   }

   struct Player: Codable {
	  let fullName: String
	  let playerID: Int
	  let appliedStatTotal: Double?
   }
}
