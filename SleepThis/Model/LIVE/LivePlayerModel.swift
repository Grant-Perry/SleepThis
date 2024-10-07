import Foundation

struct LivePlayerModel: Codable, Identifiable {
   let id: Int
   let lineupSlotId: Int
   let playerPoolEntry: PlayerPoolEntry
}

struct PlayerPoolEntry: Codable {
   let appliedStatTotal: Double
   let id: Int
   let keeperValue: Int?
   let keeperValueFuture: Int?
   let lineupLocked: Bool
   let onTeamId: Int
   let player: Player
   let rosterLocked: Bool
   let status: String?
   let tradeLocked: Bool
}

struct Player: Codable {
   let defaultPositionId: Int
   let draftRanksByRankType: [String: Int]?
   let eligibleSlots: [Int]
   let firstName: String?
   let fullName: String
   let id: Int
   let injured: Bool
   let injuryStatus: String?
   let lastName: String?
   let proTeamId: Int
   let stats: [Stat]
   let universeId: Int
}

struct Stat: Codable {
   let appliedTotal: Double
   let externalId: String
   let id: String
   let proTeamId: Int
   let scoringPeriodId: Int
   let seasonId: Int
   let statSourceId: Int
   let statSplitTypeId: Int
   let stats: [String: Double]
   let appliedStats: [String: Double]?
   let variance: [String: Double]?
}
