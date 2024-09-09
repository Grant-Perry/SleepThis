import Foundation

struct DraftModel: Identifiable, Codable {
   var id: String { "\(pick_no)" }  // Used pick_no as a unique identifier
   let pick_no: Int  // Correctly mapped as an Int per JSON
   let round: Int
   let roster_id: Int
   let player_id: String
   let picked_by: String
   let draft_slot: Int  // Add this to match the draft_slot in the JSON
   let metadata: DraftMetadata?

   var managerName: String?
   var managerAvatar: URL?

   struct DraftMetadata: Codable {
	  let years_exp: String?  // Correctly mapped as String
	  let birth_country: String?
	  let birth_date: String?
	  let college: String?
	  let first_name: String?
	  let last_name: String?
	  let position: String?
	  let team: String?
	  let number: String?  // Correctly mapped as String
	  let status: String?
	  let depth_chart_order: String?
	  let depth_chart_position: String?
   }

   enum CodingKeys: String, CodingKey {
	  case pick_no
	  case round
	  case roster_id
	  case player_id
	  case picked_by
	  case draft_slot  // Ensure this matches the JSON key
	  case metadata
   }
}
