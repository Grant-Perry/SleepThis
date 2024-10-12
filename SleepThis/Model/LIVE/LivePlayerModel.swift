import Foundation

struct LivePlayerModel: Codable {
   var teams: [Team]?
}

struct Team: Codable {
   var id: Int?
   var roster: Roster?
}

struct Roster: Codable {
   var entries: [RosterEntry]?
}

struct RosterEntry: Codable {
   var playerPoolEntry: PlayerPoolEntry?
}

struct PlayerPoolEntry: Codable {
   var player: Player?
}

struct Player: Codable {
   var id: Int?
   var fullName: String?
   var proTeamId: Int?
   var defaultPositionID: Int?
   var stats: [PlayerStat]?
}



struct PlayerStat: Codable {
   var appliedStats: [String: Double]?
}
