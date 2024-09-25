import Foundation

struct StarterModels: Identifiable {
   let id: String  // This should be the player's ID
   let playerName: String
   let position: String
   let team: String
   let jerseyNumber: String?
   let points: Double  // Fantasy points

   var playerID: String {
	  return id
   }
}
