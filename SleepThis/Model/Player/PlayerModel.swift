import SwiftUI
import Foundation

struct PlayerModel: Codable, Identifiable, Hashable {
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
   var statsId: String? // Made mutable to handle String/Int
   let searchLastName: String?
   let searchFirstName: String?
   let searchFullName: String?
   let hashtag: String?
   let injuryStartDate: String?
   let practiceParticipation: String?
   let sportradarId: String?
   let fantasyDataId: Int?
   let injuryStatus: String?
   let yahooId: String?
   let rotowireId: Int?
   let rotoworldId: Int?
   let espnId: String?
   let searchRank: Int?

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
	  case searchLastName = "search_last_name"
	  case searchFirstName = "search_first_name"
	  case searchFullName = "search_full_name"
	  case hashtag
	  case injuryStartDate = "injury_start_date"
	  case practiceParticipation = "practice_participation"
	  case sportradarId = "sportradar_id"
	  case fantasyDataId = "fantasy_data_id"
	  case injuryStatus = "injury_status"
	  case yahooId = "yahoo_id"
	  case rotowireId = "rotowire_id"
	  case rotoworldId = "rotoworld_id"
	  case espnId = "espn_id"
	  case searchRank = "search_rank"
   }

   init(from decoder: Decoder) throws {
	  let container = try decoder.container(keyedBy: CodingKeys.self)
	  id = try container.decode(String.self, forKey: .id)
	  firstName = try? container.decode(String.self, forKey: .firstName)
	  lastName = try? container.decode(String.self, forKey: .lastName)
	  fullName = try? container.decode(String.self, forKey: .fullName)
	  team = try? container.decode(String.self, forKey: .team)
	  position = try? container.decode(String.self, forKey: .position)
	  age = try? container.decode(Int.self, forKey: .age)
	  height = try? container.decode(String.self, forKey: .height)
	  weight = try? container.decode(String.self, forKey: .weight)
	  status = try? container.decode(String.self, forKey: .status)
	  college = try? container.decode(String.self, forKey: .college)
	  birthCity = try? container.decode(String.self, forKey: .birthCity)
	  birthState = try? container.decode(String.self, forKey: .birthState)
	  birthCountry = try? container.decode(String.self, forKey: .birthCountry)
	  birthDate = try? container.decode(String.self, forKey: .birthDate)
	  yearsExp = try? container.decode(Int.self, forKey: .yearsExp)
	  highSchool = try? container.decode(String.self, forKey: .highSchool)
	  fantasyPositions = try? container.decode([String].self, forKey: .fantasyPositions)
	  metadata = try? container.decode([String: String].self, forKey: .metadata)
	  newsUpdated = try? container.decode(Int.self, forKey: .newsUpdated)
	  number = try? container.decode(Int.self, forKey: .number)
	  depthChartPosition = try? container.decode(String.self, forKey: .depthChartPosition)
	  depthChartOrder = try? container.decode(Int.self, forKey: .depthChartOrder)
	  rookieYear = try? container.decode(String.self, forKey: .rookieYear)

	  // Handle both String and Int types for statsId
	  if let stringId = try? container.decode(String.self, forKey: .statsId) {
		 statsId = stringId
	  } else if let intId = try? container.decode(Int.self, forKey: .statsId) {
		 statsId = "\(intId)"
	  } else {
		 statsId = nil
	  }

	  searchLastName = try? container.decode(String.self, forKey: .searchLastName)
	  searchFirstName = try? container.decode(String.self, forKey: .searchFirstName)
	  searchFullName = try? container.decode(String.self, forKey: .searchFullName)
	  hashtag = try? container.decode(String.self, forKey: .hashtag)
	  injuryStartDate = try? container.decode(String.self, forKey: .injuryStartDate)
	  practiceParticipation = try? container.decode(String.self, forKey: .practiceParticipation)
	  sportradarId = try? container.decode(String.self, forKey: .sportradarId)
	  fantasyDataId = try? container.decode(Int.self, forKey: .fantasyDataId)
	  injuryStatus = try? container.decode(String.self, forKey: .injuryStatus)
	  yahooId = try? container.decode(String.self, forKey: .yahooId)
	  rotowireId = try? container.decode(Int.self, forKey: .rotowireId)
	  rotoworldId = try? container.decode(Int.self, forKey: .rotoworldId)
	  espnId = try? container.decode(String.self, forKey: .espnId)
	  searchRank = try? container.decode(Int.self, forKey: .searchRank)
   }

   func hash(into hasher: inout Hasher) {
	  hasher.combine(id)
   }

   static func == (lhs: PlayerModel, rhs: PlayerModel) -> Bool {
	  lhs.id == rhs.id
   }
}
