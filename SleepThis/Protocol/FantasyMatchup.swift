import Foundation

protocol FantasyMatchupProtocol {
   var teamNames: [String] { get }
   var scores: [Double] { get }
   var avatarURLs: [URL?] { get }
   var managerNames: [String] { get }
}

enum FantasyScores {
   // ESPN Models
   struct FantasyModel: Codable {
	  let teams: [Team]
	  let schedule: [Matchup]

	  struct Team: Codable {
		 let id: Int
		 let name: String
		 let roster: Roster?

		 struct Roster: Codable {
			let entries: [PlayerEntry]
		 }

		 struct PlayerEntry: Codable {
			let playerPoolEntry: PlayerPoolEntry
			let lineupSlotId: Int

			struct PlayerPoolEntry: Codable {
			   let player: Player

			   struct Player: Codable {
				  let id: Int
				  let fullName: String
				  let stats: [Stat]

				  struct Stat: Codable {
					 let scoringPeriodId: Int
					 let statSourceId: Int
					 let appliedTotal: Double?
				  }
			   }
			}
		 }
	  }

	  struct Matchup: Codable {
		 let id: Int
		 let matchupPeriodId: Int
		 let home: MatchupTeam
		 let away: MatchupTeam

		 struct MatchupTeam: Codable {
			let teamId: Int
		 }
	  }
   }

   struct FantasyMatchup: FantasyMatchupProtocol {
	  let teamNames: [String]
	  let scores: [Double]
	  let avatarURLs: [URL?]  // Add URLs here for avatars
	  let managerNames: [String]
	  let homeTeamID: Int
	  let awayTeamID: Int

	  init(homeTeamName: String, awayTeamName: String, homeScore: Double, awayScore: Double, homeAvatarURL: URL?, awayAvatarURL: URL?, homeManagerName: String, awayManagerName: String, homeTeamID: Int, awayTeamID: Int) {
		 self.teamNames = [awayTeamName, homeTeamName]
		 self.scores = [awayScore, homeScore]
		 self.avatarURLs = [awayAvatarURL, homeAvatarURL]
		 self.managerNames = [awayManagerName, homeManagerName]
		 self.homeTeamID = homeTeamID
		 self.awayTeamID = awayTeamID
	  }
   }

   // Sleeper Models
   struct SleeperLeagueResponse: Codable {
	  let leagueID: String
	  let name: String

	  enum CodingKeys: String, CodingKey {
		 case leagueID = "league_id"
		 case name
	  }
   }

   struct SleeperMatchup: Codable {
	  let roster_id: Int
	  let points: Double?
	  let matchup_id: Int
	  let starters: [String]?
	  let players: [String]?
   }

   struct SleeperLeagueSettings: Codable {
	  let scoringSettings: [String: Double]

	  enum CodingKeys: String, CodingKey {
		 case scoringSettings = "scoring_settings"
	  }
   }

   struct SleeperPlayer: Codable {
	  let player_id: String
	  let full_name: String
	  let position: String
	  let stats: [String: [String: [String: Double]]]?
   }

   struct SleeperPlayerScore {
	  let player: SleeperPlayer
	  let score: Double
   }

   static var leagueName: String {
	  if AppConstants.leagueID == AppConstants.ESPNLeagueID {
		 return "ESPN League"
	  } else if AppConstants.leagueID == AppConstants.SleeperLeagueID {
		 // Assuming you have a way to map league IDs to names, you can add more cases if needed
		 return "Sleeper League"
	  } else {
		 return "Unknown League"
	  }
   }

   
}

struct SleeperUser: Codable {
   let user_id: String
   let display_name: String
}

struct SleeperRoster: Codable {
   let roster_id: Int
   let owner_id: String?
   let metadata: [String: String]?
}

struct AnyFantasyMatchup: FantasyMatchupProtocol, Hashable {
   let teamNames: [String]
   let scores: [Double]
   let avatarURLs: [URL?]
   let managerNames: [String]
   let homeTeamID: Int
   let awayTeamID: Int
   let sleeperData: (FantasyScores.SleeperMatchup, FantasyScores.SleeperMatchup)?

   init(_ matchup: FantasyScores.FantasyMatchup, sleeperData: (FantasyScores.SleeperMatchup, FantasyScores.SleeperMatchup)? = nil) {
	  self.teamNames = matchup.teamNames
	  self.scores = matchup.scores
	  self.avatarURLs = matchup.avatarURLs
	  self.managerNames = matchup.managerNames
	  self.homeTeamID = matchup.homeTeamID
	  self.awayTeamID = matchup.awayTeamID
	  self.sleeperData = sleeperData
   }

   // Implement the `hash(into:)` method to conform to `Hashable`
   func hash(into hasher: inout Hasher) {
	  hasher.combine(teamNames)
	  hasher.combine(scores)
	  hasher.combine(managerNames)
	  hasher.combine(homeTeamID)
	  hasher.combine(awayTeamID)
   }

   // Implement the `==` operator for `Equatable` conformance, required by `Hashable`
   static func == (lhs: AnyFantasyMatchup, rhs: AnyFantasyMatchup) -> Bool {
	  return lhs.teamNames == rhs.teamNames &&
	  lhs.scores == rhs.scores &&
	  lhs.managerNames == rhs.managerNames &&
	  lhs.homeTeamID == rhs.homeTeamID &&
	  lhs.awayTeamID == rhs.awayTeamID
   }
}

