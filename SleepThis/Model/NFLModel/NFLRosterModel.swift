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
	  let position: String?  // Added position field
	  let links: [Link]?
	  let birthPlace: BirthPlace?
	  let college: College?
	  let team: Team? // Player's team information
	  let coach: [Coach]? // Player's coach information

	  struct Team: Codable {
		 let id: String
		 let abbreviation: String
		 let name: String
		 let displayName: String
		 let color: String
		 let logo: String
		 let record: String
		 let standing: String

		 private enum CodingKeys: String, CodingKey {
			case id
			case abbreviation
			case name
			case displayName
			case color
			case logo
			case record = "recordSummary"
			case standing = "standingSummary"
		 }
	  }

	  struct Coach: Codable {
		 let id: String
		 let firstName: String
		 let lastName: String
		 let experience: Int
	  }
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
}
