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
   }

   init(from decoder: Decoder) throws {
	  let container = try decoder.container(keyedBy: CodingKeys.self)
	  id = try container.decode(String.self, forKey: .id)
	  firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
	  lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
	  fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
	  team = try container.decodeIfPresent(String.self, forKey: .team)
	  position = try container.decodeIfPresent(String.self, forKey: .position)
	  age = try container.decodeIfPresent(Int.self, forKey: .age)
	  height = try container.decodeIfPresent(String.self, forKey: .height)
	  weight = try container.decodeIfPresent(String.self, forKey: .weight)
	  status = try container.decodeIfPresent(String.self, forKey: .status)
	  college = try container.decodeIfPresent(String.self, forKey: .college)
	  birthCity = try container.decodeIfPresent(String.self, forKey: .birthCity)
	  birthState = try container.decodeIfPresent(String.self, forKey: .birthState)
	  birthCountry = try container.decodeIfPresent(String.self, forKey: .birthCountry)
	  birthDate = try container.decodeIfPresent(String.self, forKey: .birthDate)
	  yearsExp = try container.decodeIfPresent(Int.self, forKey: .yearsExp)
	  highSchool = try container.decodeIfPresent(String.self, forKey: .highSchool)
	  fantasyPositions = try container.decodeIfPresent([String].self, forKey: .fantasyPositions)
	  metadata = try container.decodeIfPresent([String: String].self, forKey: .metadata)
	  newsUpdated = try container.decodeIfPresent(Int.self, forKey: .newsUpdated)
	  number = try container.decodeIfPresent(Int.self, forKey: .number)
	  depthChartPosition = try container.decodeIfPresent(String.self, forKey: .depthChartPosition)
	  depthChartOrder = try container.decodeIfPresent(Int.self, forKey: .depthChartOrder)
	  rookieYear = try container.decodeIfPresent(String.self, forKey: .rookieYear)

	  // Decode statsId as either String or Number
	  if let statsIdString = try? container.decode(String.self, forKey: .statsId) {
		 statsId = statsIdString
	  } else if let statsIdInt = try? container.decode(Int.self, forKey: .statsId) {
		 statsId = String(statsIdInt)
	  } else {
		 statsId = nil
	  }
   }
}
