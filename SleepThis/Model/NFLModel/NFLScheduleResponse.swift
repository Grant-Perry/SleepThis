import Foundation

struct NFLScheduleResponse: Codable {
   let events: [Event]

   struct Event: Codable {
	  let name: String
	  let shortName: String
	  let competitions: [Competition]
	  let status: Status
	  let date: String

	  struct Competition: Codable {
		 let competitors: [Competitor]
		 let status: Status
		 let venue: Venue?

		 struct Competitor: Codable {
			let team: Team
			let homeAway: String
			let score: String
		 }

		 struct Team: Codable {
			let displayName: String
			let abbreviation: String
		 }

		 struct Venue: Codable {
			let fullName: String?
		 }
	  }

	  struct Status: Codable {
		 let type: StatusType
		 struct StatusType: Codable {
			let name: String // e.g., "STATUS_SCHEDULED", "STATUS_IN_PROGRESS", "STATUS_FINAL"
		 }
	  }
   }
}

struct NFLScheduleGame {
   let homeTeam: String
   let awayTeam: String
   let homeAbbrev: String
   let awayAbbrev: String
   let homeScore: Int?
   let awayScore: Int?
   let startTime: Date
   let dayOfWeek: String
   let displayTime: String
   let status: GameStatus

   enum GameStatus {
	  case scheduled
	  case inProgress
	  case final
   }
}
