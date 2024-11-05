import Foundation

struct SleeperScoring {
   struct ScoringSettings: Codable {
	  var passYards: Double
	  var passTouchdowns: Double
	  var passInterceptions: Double
	  var rushYards: Double
	  var rushTouchdowns: Double
	  var receivingYards: Double
	  var receivingTouchdowns: Double
	  var fumblesLost: Double

	  // Default scoring settings in case no specific league settings are provided
	  static func defaultSettings() -> ScoringSettings {
		 return ScoringSettings(
			passYards: 0.04,
			passTouchdowns: 4.0,
			passInterceptions: -2.0,
			rushYards: 0.1,
			rushTouchdowns: 6.0,
			receivingYards: 0.1,
			receivingTouchdowns: 6.0,
			fumblesLost: -2.0
		 )
	  }
   }

   struct SleeperLeagueInfo: Codable {
	  let scoringSettings: ScoringSettings
   }
}
