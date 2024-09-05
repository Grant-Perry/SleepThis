import Foundation

struct DraftPickModel: Identifiable, Codable {
   var id: UUID = UUID()
   let pickNo: Int
   let round: Int
   let metadata: Metadata

   struct Metadata: Codable {
	  let firstName: String
	  let lastName: String
	  let position: String
	  let team: String
   }
}
