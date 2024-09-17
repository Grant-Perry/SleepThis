import Foundation

enum NFLRosterModel {
   struct TeamRosterResponse: Codable {
	  let timestamp: String
	  let status: String
	  let season: Season
	  let athletes: [AthleteGroup]
	  let team: Team // Single team
	  let coach: CoachOrCoaches? // Modified to handle both single coach and array of coaches

	  private enum CodingKeys: String, CodingKey {
		 case timestamp
		 case status
		 case season
		 case athletes
		 case team
		 case coach
	  }
   }

   struct CoachOrCoaches: Codable {
	  let coachArray: [Coach]?
	  let coach: Coach?

	  init(from decoder: Decoder) throws {
		 let container = try decoder.singleValueContainer()

		 // Try to decode as an array of coaches
		 if let coachArray = try? container.decode([Coach].self) {
			self.coachArray = coachArray
			self.coach = nil
		 }
		 // Try to decode as a single coach dictionary
		 else if let coach = try? container.decode(Coach.self) {
			self.coach = coach
			self.coachArray = nil
		 } else {
			throw DecodingError.typeMismatch(CoachOrCoaches.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected single coach or an array of coaches"))
		 }
	  }
   }

   struct Coach: Codable {
	  let id: String
	  let firstName: String
	  let lastName: String
	  let experience: Int
   }

   struct Season: Codable {
	  let year: Int
	  let displayName: String
	  let type: Int
	  let name: String
   }

   struct AthleteGroup: Codable {
	  let position: String
	  let items: [NFLPlayer]
   }

   struct NFLPlayer: Codable, Identifiable {
	  let uid: String
	  let imageID: String // New property to map the actual ID for the image
	  let firstName: String
	  let lastName: String
	  let fullName: String
	  let displayName: String
	  let weight: Double?
	  let displayWeight: String?
	  let height: Double?
	  let displayHeight: String?
	  let age: Int?
	  let position: Position?
	  let college: College?
	  var team: Team? // Single team per player
	  var coach: Coach? // Single coach per player
	  var id: String { uid } // Keep uid for fallback or other uses

	  var imageUrl: URL? {
		 URL(string: "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/\(imageID).png")
	  }

	  private enum CodingKeys: String, CodingKey {
		 case uid
		 case imageID = "id" // Direct mapping to the ID in the JSON response
		 case firstName, lastName, fullName, displayName, weight, displayWeight, height, displayHeight, age, position, college, team, coach
	  }
   }


   struct Position: Codable {
	  let name: String
	  let displayName: String
   }

   struct Team: Codable {
	  let id: String
	  let abbreviation: String
	  let displayName: String
	  let color: String?
	  let logo: String?
   }

   struct BirthPlace: Codable {
	  let city: String?
	  let state: String?
	  let country: String?
   }

   struct College: Codable {
	  let name: String
   }
}
