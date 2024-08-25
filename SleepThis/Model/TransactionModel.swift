import Foundation

struct TransactionModel: Identifiable, Codable {
   var id = UUID() // Unique ID for SwiftUI Identifiable conformance
   let status: String
   let type: String
   let transaction_id: String
   let status_updated: Int
   let created: Int
   let leg: Int
   let roster_ids: [Int]
   let draft_picks: [DraftPick]?
   let adds: [String: Int]?
   let drops: [String: Int]?
   let waiver_budget: [WaiverBudget]?
   let metadata: Metadata?
   let settings: Settings?
   let consenter_ids: [Int]?

   struct DraftPick: Codable {
	  let season: String?
	  let round: Int?
	  let roster_id: Int?
	  let previous_owner_id: Int?
	  let owner_id: Int?
   }

   struct WaiverBudget: Codable {
	  let sender: Int?
	  let receiver: Int?
	  let amount: Int?
   }

   struct Metadata: Codable {
	  let notes: String?
   }

   struct Settings: Codable {
	  let seq: Int?
	  let waiver_bid: Int?
	  let priority: Int?
   }
}
