import Foundation

// Namespace for Sleeper Fantasy
enum SleeperFantasy {
   struct SleeperFantasyModel: Codable {
	  let starters: [String]  // List of player IDs that are starters
	  let rosterID: Int       // Roster ID for this team
	  let players: [String]   // List of all player IDs in the roster
	  let matchupID: Int      // ID of the matchup
	  let points: Double      // Total points scored by this team
	  let customPoints: Double? // If points have been manually overridden
	  let manager: Manager?   // Manager information for this team
   }

   struct Manager: Codable {
	  let userID: String      // User ID of the manager
	  let username: String    // Username of the manager
	  let displayName: String // Display name of the manager
	  let avatar: String?     // Avatar ID for the manager

	  var avatarURL: URL? {
		 guard let avatar = avatar else { return nil }
		 return URL(string: "https://sleepercdn.com/avatars/\(avatar)")
	  }

	  var avatarThumbnailURL: URL? {
		 guard let avatar = avatar else { return nil }
		 return URL(string: "https://sleepercdn.com/avatars/thumbs/\(avatar)")
	  }
   }
}
