import Foundation

struct ESPNPlayerModel: Codable {
   let id: String
   let fullName: String
   let team: String?
   let position: String?
   let headshotURL: String?

   enum CodingKeys: String, CodingKey {
	  case id = "id"
	  case fullName = "fullName"
	  case team = "teamName"
	  case position = "positionName"
	  case headshotURL = "headshotUrl"
   }
}
