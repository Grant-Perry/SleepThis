import SwiftUI
import Foundation

struct PlayerModel: Codable, Identifiable {
   let id: String
   let firstName: String?
   let lastName: String?
   let fullName: String?
   let team: String?
   let position: String?
   let age: Int?
   let height: String?
   let weight: String?
   let status: String?
   let college: String?
   let birthCity: String?
   let birthState: String?
   let birthCountry: String?
   let birthDate: String?
   let yearsExp: Int?
   let highSchool: String?
   let fantasyPositions: [String]?
   let metadata: [String: String]?
   let newsUpdated: Int?
   let number: Int?
   let depthChartPosition: String?
   let depthChartOrder: Int?
   let rookieYear: String?
   let statsId: String?
   let searchLastName: String?  // New
   let searchFirstName: String? // New
   let searchFullName: String?  // New
   let hashtag: String?         // New
   let injuryStartDate: String? // New
   let practiceParticipation: String? // New
   let sportradarId: String?    // New
   let fantasyDataId: Int?      // New
   let injuryStatus: String?    // New
   let yahooId: String?         // New
   let rotowireId: Int?         // New
   let rotoworldId: Int?        // New
   let espnId: String?          // New
   let searchRank: Int?         // New

   enum CodingKeys: String, CodingKey {
	  case id = "player_id"
	  case firstName = "first_name"
	  case lastName = "last_name"
	  case fullName = "full_name"
	  case team
	  case position
	  case age
	  case height
	  case weight
	  case status
	  case college
	  case birthCity = "birth_city"
	  case birthState = "birth_state"
	  case birthCountry = "birth_country"
	  case birthDate = "birth_date"
	  case yearsExp = "years_exp"
	  case highSchool = "high_school"
	  case fantasyPositions = "fantasy_positions"
	  case metadata
	  case newsUpdated = "news_updated"
	  case number
	  case depthChartPosition = "depth_chart_position"
	  case depthChartOrder = "depth_chart_order"
	  case rookieYear = "rookie_year"
	  case statsId = "stats_id"
	  case searchLastName = "search_last_name"  // New
	  case searchFirstName = "search_first_name" // New
	  case searchFullName = "search_full_name"  // New
	  case hashtag         // New
	  case injuryStartDate = "injury_start_date" // New
	  case practiceParticipation = "practice_participation" // New
	  case sportradarId = "sportradar_id"    // New
	  case fantasyDataId = "fantasy_data_id" // New
	  case injuryStatus = "injury_status"    // New
	  case yahooId = "yahoo_id"              // New
	  case rotowireId = "rotowire_id"        // New
	  case rotoworldId = "rotoworld_id"      // New
	  case espnId = "espn_id"                // New
	  case searchRank = "search_rank"        // New
   }
}
