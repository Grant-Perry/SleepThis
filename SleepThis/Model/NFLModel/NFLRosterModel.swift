import Foundation

// MARK: - ESPN Fantasy Models - holds the complete fantasy data structure for the ESPN API
enum NFLRosterModel {
   struct TeamRosterResponse: Codable {
	  let timestamp: String
	  let status: String
	  let season: Season
	  var athletes: [AthleteGroup]
	  let team: Team
	  let coach: CoachOrCoaches?

	  private enum CodingKeys: String, CodingKey {
		 case timestamp, status, season, athletes, team, coach
	  }
   }

   struct CoachOrCoaches: Codable {
	  let coachArray: [Coach]?
	  let coach: Coach?

	  init(from decoder: Decoder) throws {
		 let container = try decoder.singleValueContainer()
		 if let coachArray = try? container.decode([Coach].self) {
			self.coachArray = coachArray
			self.coach = nil
		 } else if let coach = try? container.decode(Coach.self) {
			self.coach = coach
			self.coachArray = nil
		 } else {
			throw DecodingError.typeMismatch(CoachOrCoaches.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected single coach or an array of coaches"))
		 }
	  }
   }

   struct Coach: Codable {
	  let id: String
	  let firstName: String
	  let lastName: String
	  let experience: Int
   }

   struct Season: Codable {
	  let year: Int
	  let displayName: String
	  let type: Int
	  let name: String
   }

   struct AthleteGroup: Codable {
	  let position: String
	  var items: [NFLPlayer]
   }

   struct NFLPlayer: Codable, Identifiable {
	  let uid: String
	  let imageID: String
	  let firstName: String
	  let lastName: String
	  let fullName: String
	  let displayName: String
	  let jersey: String?
	  let weight: Double?
	  let displayWeight: String?
	  let height: Double?
	  let displayHeight: String?
	  let age: Int?
	  let position: Position?
	  let college: College?
	  var team: Team?
	  var coach: Coach?
	  var status: PlayerStatus?  // New PlayerStatus field
	  var injuries: [Injury]?    // New injuries field
	  var id: String { uid }

	  var imageUrl: URL? {
		 URL(string: "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/\(imageID).png")
	  }

	  var positionAbbreviation: String? {
		 position?.abbreviation
	  }

	  private enum CodingKeys: String, CodingKey {
		 case uid, imageID = "id", firstName, lastName, fullName, displayName, jersey, weight, displayWeight, height, displayHeight, age, position, college, status, injuries
	  }
   }

   // Struct for Player Status
   struct PlayerStatus: Codable {
	  let id: String
	  let name: String
	  let type: String
	  let abbreviation: String
   }

   // Struct for Player Injuries
   struct Injury: Codable {
	  let status: String
	  let date: String
   }

   struct Position: Codable {
	  let name: String
	  let displayName: String
	  let abbreviation: String
   }

   struct Team: Codable {
	  let id: String
	  let abbreviation: String
	  let displayName: String
	  let color: String?
	  let logo: String?
   }

   struct College: Codable {
	  let name: String
   }

   // This function applies team and coach after decoding
   static func applyTeamAndCoachToPlayers(_ rosterResponse: inout TeamRosterResponse) {
	  // Assign the team and coach to each player in each group
	  for (groupIndex, group) in rosterResponse.athletes.enumerated() {
		 for (playerIndex, _) in group.items.enumerated() {
			var updatedPlayer = rosterResponse.athletes[groupIndex].items[playerIndex]
			updatedPlayer.team = rosterResponse.team
			updatedPlayer.coach = rosterResponse.coach?.coach ?? rosterResponse.coach?.coachArray?.first
			rosterResponse.athletes[groupIndex].items[playerIndex] = updatedPlayer // Reassign back after mutating
		 }
	  }
   }

   // Enhanced Method with Additional Debug Statements
   static func getPlayerInfo(by fullName: String, from roster: [NFLPlayer]) -> NFLPlayer? {
	  // Print the number of players in the roster
	  print("[getPlayerInfo:] Total players in roster: \(roster.count)")

	  // Print all player names in the roster for verification
//	  print("[getPlayerInfo:] Roster contains the following players:")
//	  for player in roster {
//		 print(" - \(player.fullName)")
//	  }

	  // Clean up and match the full name
	  let cleanedFullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

	  // Attempt to find player by cleaned full name
	  let player = roster.first(where: { $0.fullName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == cleanedFullName })

	  // Debug prints for verification
//	  if let player = player {
////		 print("[getPlayerInfo:] Found player: \(player.fullName)")
////		 print("[getPlayerInfo:] team.color = \(player.team?.color ?? "No Color Found")")
////		 print("[getPlayerInfo:] team.logo = \(player.team?.logo ?? "No Logo Found")")
//	  } else {
//		 print("[getPlayerInfo:] Player with name '\(cleanedFullName)' not found in roster.")
//	  }

	  return player
   }



}

// Decoding and applying team/coach logic integrated
func fetchTeamRosterData(from jsonData: Data) throws -> NFLRosterModel.TeamRosterResponse {
   let decoder = JSONDecoder()
   var rosterResponse = try decoder.decode(NFLRosterModel.TeamRosterResponse.self, from: jsonData)

   // Apply the team and coach to all players
   NFLRosterModel.applyTeamAndCoachToPlayers(&rosterResponse)

   return rosterResponse
}
