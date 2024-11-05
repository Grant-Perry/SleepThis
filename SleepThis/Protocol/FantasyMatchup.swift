import SwiftUI
import Combine

protocol FantasyMatchupProtocol {
   var teamNames: [String] { get }
   var scores: [Double] { get }
   var avatarURLs: [URL?] { get }
   var managerNames: [String] { get }
}




struct AnyFantasyMatchup: FantasyMatchupProtocol {
   let teamNames: [String]
   let scores: [Double]
   let avatarURLs: [URL?]
   let managerNames: [String]
   let homeTeamID: Int
   let awayTeamID: Int
   let sleeperData: FantasyScores.SleeperMatchup?

   init(_ matchup: FantasyScores.FantasyMatchup, sleeperData: FantasyScores.SleeperMatchup? = nil) {
	  self.teamNames = matchup.teamNames
	  self.scores = matchup.scores
	  self.avatarURLs = matchup.avatarURLs
	  self.managerNames = matchup.managerNames
	  self.homeTeamID = matchup.homeTeamID
	  self.awayTeamID = matchup.awayTeamID
	  self.sleeperData = sleeperData
   }
}



