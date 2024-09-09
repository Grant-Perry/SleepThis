import Foundation

struct UserModel: Codable, Identifiable {
   let user_id: String // This will be used as the unique identifier for SwiftUI views
   let username: String
   let display_name: String?
   let avatar: String?

   var id: String { user_id } // Use user_id as the unique id for Identifiable conformance

   var avatarURL: URL? {
	  guard let avatar = avatar else { return nil }
	  return URL(string: "https://sleepercdn.com/avatars/thumbs/\(avatar)")
   }

   enum CodingKeys: String, CodingKey {
	  case username
	  case user_id = "user_id"
	  case display_name = "display_name"
	  case avatar
   }
}
