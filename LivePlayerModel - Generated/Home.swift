//
//  Home.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct Home: Codable {

  enum CodingKeys: String, CodingKey {
    case pointsByScoringPeriod
    case cumulativeScore
    case totalPointsLive
    case adjustment
    case rosterForCurrentScoringPeriod
    case totalPoints
    case rosterForMatchupPeriodDelayed
    case cumulativeScoreLive
    case tiebreak
    case teamId
  }

  var pointsByScoringPeriod: PointsByScoringPeriod?
  var cumulativeScore: CumulativeScore?
  var totalPointsLive: Float?
  var adjustment: Int?
  var rosterForCurrentScoringPeriod: RosterForCurrentScoringPeriod?
  var totalPoints: Float?
  var rosterForMatchupPeriodDelayed: RosterForMatchupPeriodDelayed?
  var cumulativeScoreLive: CumulativeScoreLive?
  var tiebreak: Int?
  var teamId: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    pointsByScoringPeriod = try container.decodeIfPresent(PointsByScoringPeriod.self, forKey: .pointsByScoringPeriod)
    cumulativeScore = try container.decodeIfPresent(CumulativeScore.self, forKey: .cumulativeScore)
    totalPointsLive = try container.decodeIfPresent(Float.self, forKey: .totalPointsLive)
    adjustment = try container.decodeIfPresent(Int.self, forKey: .adjustment)
    rosterForCurrentScoringPeriod = try container.decodeIfPresent(RosterForCurrentScoringPeriod.self, forKey: .rosterForCurrentScoringPeriod)
    totalPoints = try container.decodeIfPresent(Float.self, forKey: .totalPoints)
    rosterForMatchupPeriodDelayed = try container.decodeIfPresent(RosterForMatchupPeriodDelayed.self, forKey: .rosterForMatchupPeriodDelayed)
    cumulativeScoreLive = try container.decodeIfPresent(CumulativeScoreLive.self, forKey: .cumulativeScoreLive)
    tiebreak = try container.decodeIfPresent(Int.self, forKey: .tiebreak)
    teamId = try container.decodeIfPresent(Int.self, forKey: .teamId)
  }

}
