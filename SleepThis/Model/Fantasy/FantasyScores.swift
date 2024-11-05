import Foundation

enum FantasyScores {
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
				  let position: String?
				  let stats: [Stat]

				  struct Stat: Codable {
					 let scoringPeriodId: Int
					 let statSourceId: Int
					 let appliedTotal: Double?
					 let passYards: Double?
					 let passTouchdowns: Double?
					 let passInterceptions: Double?
					 let rushYards: Double?
					 let rushTouchdowns: Double?
					 let receivingYards: Double?
					 let receivingTouchdowns: Double?
					 let fumblesLost: Double?

					 // Initializer with default values to handle missing data
					 init(
						scoringPeriodId: Int,
						statSourceId: Int,
						appliedTotal: Double? = 0,
						passYards: Double? = 0,
						passTouchdowns: Double? = 0,
						passInterceptions: Double? = 0,
						rushYards: Double? = 0,
						rushTouchdowns: Double? = 0,
						receivingYards: Double? = 0,
						receivingTouchdowns: Double? = 0,
						fumblesLost: Double? = 0
					 ) {
						self.scoringPeriodId = scoringPeriodId
						self.statSourceId = statSourceId
						self.appliedTotal = appliedTotal
						self.passYards = passYards
						self.passTouchdowns = passTouchdowns
						self.passInterceptions = passInterceptions
						self.rushYards = rushYards
						self.rushTouchdowns = rushTouchdowns
						self.receivingYards = receivingYards
						self.receivingTouchdowns = receivingTouchdowns
						self.fumblesLost = fumblesLost
					 }
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
	  let avatarURLs: [URL?]
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
	  let points: Double
	  let matchup_id: Int
	  let starters: [String]
	  let players: [String]
   }
}
