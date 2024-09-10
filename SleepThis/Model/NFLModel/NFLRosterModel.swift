import Foundation

enum NFLRosterModel {
   struct TeamRosterResponse: Codable {
	  let timestamp: String
	  let status: String
	  let season: Season
	  let athletes: [AthleteGroup]
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
	  var id: String { uid }
	  let uid: String
	  let guid: String
	  let firstName: String
	  let lastName: String
	  let fullName: String
	  let displayName: String
	  let shortName: String
	  let weight: Double?
	  let displayWeight: String?
	  let height: Double?
	  let displayHeight: String?
	  let age: Int?
	  let dateOfBirth: String?
	  let links: [Link]?
	  let birthPlace: BirthPlace?
	  let college: College?
//	  var position: String?

	  // Add any other fields that are present in the JSON
   }

   struct Link: Codable {
	  let language: String
	  let rel: [String]
	  let href: String
	  let text: String
	  let shortText: String
	  let isExternal: Bool
	  let isPremium: Bool
   }

   struct BirthPlace: Codable {
	  let city: String?
	  let state: String?
	  let country: String?
   }

   struct College: Codable {
	  let id: String
	  let mascot: String?
	  let name: String
	  let shortName: String
	  let abbrev: String
	  let logos: [Logo]?
   }

   struct Logo: Codable {
	  let href: String
	  let width: Int
	  let height: Int
	  let alt: String?
	  let rel: [String]?
	  let lastUpdated: String?
   }

   // This enum is no longer needed as we're using optionals for potentially missing fields
   // enum StringOrInt: Codable { ... }
}
