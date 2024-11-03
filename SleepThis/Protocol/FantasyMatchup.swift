import SwiftUI
import Combine

protocol FantasyMatchup {
   var teamNames: [String] { get }
   var scores: [Double] { get }
   var avatarURLs: [URL?] { get }
   var managerNames: [String] { get }
}


enum ESPNFantasy {
   struct ESPNFantasyModel: Codable {
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
}

struct SleeperMatchup: Codable, FantasyMatchup {
   let roster_id: Int
   let points: Double
   let matchup_id: Int
   let starters: [String]
   let players: [String]

   // FantasyMatchup protocol properties
   var teamNames: [String] {
	  return ["Team \(roster_id)"]
   }

   var scores: [Double] {
	  return [points]
   }

   var avatarURLs: [URL?] {
	  return [nil] // Placeholder; populate with actual URL if available
   }

   var managerNames: [String] {
	  return ["Manager \(roster_id)"] // Placeholder; populate with actual manager name if available
   }
}


struct ESPNFantasyMatchup: FantasyMatchup {
   var teamNames: [String]
   var scores: [Double]
   var avatarURLs: [URL?]
   var managerNames: [String]

   init(homeTeamName: String, awayTeamName: String, homeScore: Double, awayScore: Double, homeAvatarURL: URL? = nil, awayAvatarURL: URL? = nil, homeManagerName: String, awayManagerName: String) {
	  self.teamNames = [awayTeamName, homeTeamName]
	  self.scores = [awayScore, homeScore]
	  self.avatarURLs = [awayAvatarURL, homeAvatarURL]
	  self.managerNames = [awayManagerName, homeManagerName]
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

struct AnyFantasyMatchup: FantasyMatchup {
   private let _teamNames: () -> [String]
   private let _scores: () -> [Double]
   private let _avatarURLs: () -> [URL?]
   private let _managerNames: () -> [String]

   init<T: FantasyMatchup>(_ matchup: T) {
	  _teamNames = { matchup.teamNames }
	  _scores = { matchup.scores }
	  _avatarURLs = { matchup.avatarURLs }
	  _managerNames = { matchup.managerNames }
   }

   var teamNames: [String] { _teamNames() }
   var scores: [Double] { _scores() }
   var avatarURLs: [URL?] { _avatarURLs() }
   var managerNames: [String] { _managerNames() }
}









