import Foundation

enum NFLRosterModel {
   // A custom type to handle both string and integer values in the statsID
   enum StringOrInt: Codable {
	  case string(String)
	  case int(Int)

	  init(from decoder: Decoder) throws {
		 let container = try decoder.singleValueContainer()
		 if let intValue = try? container.decode(Int.self) {
			self = .int(intValue)
			return
		 }
		 if let stringValue = try? container.decode(String.self) {
			self = .string(stringValue)
			return
		 }
		 throw DecodingError.typeMismatch(StringOrInt.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected string or int value"))
	  }

	  func encode(to encoder: Encoder) throws {
		 var container = encoder.singleValueContainer()
		 switch self {
			case .string(let value):
			   try container.encode(value)
			case .int(let value):
			   try container.encode(value)
		 }
	  }
   }

   struct NFLPlayer: Codable, Identifiable {
	  var id: String { playerID }
	  let playerID: String
	  let fullName: String
	  let teamName: String
	  let statsID: StringOrInt // Use the flexible enum here
	  let position: String?     // Optional position of the player
	  let jerseyNumber: String? // Optional jersey number
	  let height: String?       // Optional height of the player
	  let weight: String?       // Optional weight of the player
	  let age: Int?             // Optional age
	  let experience: String?   // Optional experience level (e.g., "3rd season")
	  let college: String?      // Optional college information
   }

   struct NFLTeam: Codable {
	  let id: String
	  let abbreviation: String?
	  let location: String?  // Make this optional
	  let nickname: String?
	  let displayName: String?
	  let logos: [Logo]?     // Optional logo information
	  let color: String?     // Team's main color
	  let alternateColor: String? // Team's alternate color
   }

   struct Logo: Codable {
	  let href: String
	  let width: Int
	  let height: Int
   }
}
