// NFLScheduleModel.swift
import Foundation

struct NFLScheduleModel: Codable {
   let events: [Event]

   struct Event: Codable {
	  let id: String
	  let date: String
	  let shortName: String
	  let competitions: [Competition]
	  let status: EventStatus
   }

   struct Competition: Codable {
	  let startDate: String
	  let competitors: [Competitor]
	  let status: CompetitionStatus
   }

   struct Competitor: Codable {
	  let homeAway: String
	  let winner: Bool?
	  let team: Team
	  let score: String
   }

   struct Team: Codable {
	  let abbreviation: String
	  let displayName: String
   }

   struct EventStatus: Codable {
	  let type: StatusType
   }

   struct CompetitionStatus: Codable {
	  let type: StatusType
   }

   struct StatusType: Codable {
	  let state: String
	  let detail: String
	  let shortDetail: String
   }
}

struct MatchupInfo {
   let homeTeam: String
   let awayTeam: String
   let startTime: Date
   let isLive: Bool
   let homeScore: Int?
   let awayScore: Int?
   let gameDetail: String
}
