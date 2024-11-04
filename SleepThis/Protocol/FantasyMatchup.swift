import SwiftUI
import Combine

protocol FantasyMatchupProtocol {
   var teamNames: [String] { get }
   var scores: [Double] { get }
   var avatarURLs: [URL?] { get }
   var managerNames: [String] { get }
}

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

struct AnyFantasyMatchup: FantasyMatchupProtocol {
   let teamNames: [String]
   let scores: [Double]
   let avatarURLs: [URL?]
   let managerNames: [String]
   let homeTeamID: Int
   let awayTeamID: Int

   init(_ matchup: FantasyScores.FantasyMatchup) {
	  self.teamNames = matchup.teamNames
	  self.scores = matchup.scores
	  self.avatarURLs = matchup.avatarURLs
	  self.managerNames = matchup.managerNames
	  self.homeTeamID = matchup.homeTeamID
	  self.awayTeamID = matchup.awayTeamID
   }
}
