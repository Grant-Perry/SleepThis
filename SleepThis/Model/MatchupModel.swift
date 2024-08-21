import SwiftUI

import Foundation

struct MatchupModel: Identifiable, Codable {
   var id: UUID = UUID()
   var starters: [String]
   var roster_id: Int
   var players: [String]
   var matchup_id: Int
   var points: Double
   var custom_points: Double?

   enum CodingKeys: String, CodingKey {
	  case starters
	  case roster_id
	  case players
	  case matchup_id
	  case points
	  case custom_points
   }
}

