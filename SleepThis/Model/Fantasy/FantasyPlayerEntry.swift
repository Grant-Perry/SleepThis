import Foundation

struct FantasyPlayerEntry: Identifiable {
   let id = UUID()
   let playerID: String
   let fullName: String
   let position: String
   let score: Double
}
