import SwiftUI
import Foundation

struct PlayerModel: Codable, Identifiable {
   let id: String
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

   enum CodingKeys: String, CodingKey {
	  case id = "player_id"
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
   }
}
