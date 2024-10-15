import SwiftUI

enum StatType: String {
   case passAttempts = "0"
   case passCompletions = "1"
   case passYards = "3"
   case passTouchdowns = "4"
   case interceptionsThrown = "19"
   case sacksTaken = "20"

   case rushAttempts = "23"
   case rushYards = "24"
   case rushTouchdowns = "25"

   case receptions = "41"
   case receivingYards = "42"
   case receivingTouchdowns = "43"
   case fumblesLostReception = "44"

   case fieldGoalsMade = "51"
   case fieldGoalsMissed = "52"
   case extraPointsMade = "53"
   case extraPointsMissed = "54"

   case defensivePointsAllowed = "101"
   case defensiveSacks = "102"
   case defensiveInterceptions = "103"
   case defensiveFumblesRecovered = "104"
   case defensiveTouchdowns = "105"
   case specialTeamsTouchdowns = "106"

   case twoPointConversions = "123"
   case fumblesLost = "124"
   case totalYards = "129"

   var description: String {
	  switch self {
		 case .passAttempts: return "Pass Attempts"
		 case .passCompletions: return "Pass Completions"
		 case .passYards: return "Pass Yards"
		 case .passTouchdowns: return "Pass Touchdowns"
		 case .interceptionsThrown: return "Interceptions Thrown"
		 case .sacksTaken: return "Sacks Taken"
		 case .rushAttempts: return "Rush Attempts"
		 case .rushYards: return "Rush Yards"
		 case .rushTouchdowns: return "Rush Touchdowns"
		 case .receptions: return "Receptions"
		 case .receivingYards: return "Receiving Yards"
		 case .receivingTouchdowns: return "Receiving Touchdowns"
		 case .fumblesLostReception: return "Fumbles Lost (Reception)"
		 case .fieldGoalsMade: return "Field Goals Made"
		 case .fieldGoalsMissed: return "Field Goals Missed"
		 case .extraPointsMade: return "Extra Points Made"
		 case .extraPointsMissed: return "Extra Points Missed"
		 case .defensivePointsAllowed: return "Defensive Points Allowed"
		 case .defensiveSacks: return "Defensive Sacks"
		 case .defensiveInterceptions: return "Defensive Interceptions"
		 case .defensiveFumblesRecovered: return "Defensive Fumbles Recovered"
		 case .defensiveTouchdowns: return "Defensive Touchdowns"
		 case .specialTeamsTouchdowns: return "Special Teams Touchdowns"
		 case .twoPointConversions: return "Two-Point Conversions"
		 case .fumblesLost: return "Fumbles Lost"
		 case .totalYards: return "Total Yards"
	  }
   }
}
