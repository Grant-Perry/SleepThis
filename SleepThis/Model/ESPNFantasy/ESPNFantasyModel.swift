//import Foundation
//
//enum ESPNFantasy {
//   struct ESPNFantasyModel: Codable {
//	  let teams: [Team]
//	  let schedule: [Matchup]
//
//	  struct Team: Codable {
//		 let id: Int
//		 let name: String
//		 let roster: Roster?
//
//		 struct Roster: Codable {
//			let entries: [PlayerEntry]
//		 }
//
//		 struct PlayerEntry: Codable {
//			let playerPoolEntry: PlayerPoolEntry
//			let lineupSlotId: Int
//
//			struct PlayerPoolEntry: Codable {
//			   let player: Player
//
//			   struct Player: Codable {
//				  let fullName: String
//				  let stats: [Stat]
//
//				  struct Stat: Codable {
//					 let scoringPeriodId: Int
//					 let statSourceId: Int
//					 let appliedTotal: Double?
//				  }
//			   }
//			}
//		 }
//	  }
//
//	  struct Matchup: Codable, Identifiable {
//		 let id: Int
////		 var uuid = UUID()
//		 let away: TeamMatchup
//		 let home: TeamMatchup
//		 let winner: String?
//		 let matchupPeriodId: Int
//
//		 struct TeamMatchup: Codable {
//			let teamId: Int
//			let roster: Roster?
//		 }
//	  }
//   }
//}
