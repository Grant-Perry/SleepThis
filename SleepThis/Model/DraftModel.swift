import Foundation

struct DraftModel: Identifiable, Codable {
   var id: String { pick_id }
   let pick_id: String
   let round: Int
   let roster_id: Int
   let player_id: String
   let picked_by: String
   let metadata: DraftMetadata?

   var managerName: String?
   var managerAvatar: URL?

   struct DraftMetadata: Codable {
	  let years_exp: Int?
	  let birth_country: String?
	  let birth_date: String?
	  let college: String?
	  let first_name: String?
	  let last_name: String?
	  let position: String?
	  let team: String?
	  let number: Int?
	  let status: String?
	  let depth_chart_order: String? // Ensure this matches the JSON response
	  let depth_chart_position: String? // If applicable, include this
   }

   enum CodingKeys: String, CodingKey {
	  case pick_id
	  case round
	  case roster_id
	  case player_id
	  case picked_by
	  case metadata
   }
}
