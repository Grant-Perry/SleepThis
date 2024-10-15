//
//  Away.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct Away: Codable {

  enum CodingKeys: String, CodingKey {
    case rosterForCurrentScoringPeriod
    case adjustment
    case cumulativeScoreLive
    case cumulativeScore
    case rosterForMatchupPeriodDelayed
    case tiebreak
    case totalPoints
    case totalPointsLive
    case teamId
    case pointsByScoringPeriod
  }

  var rosterForCurrentScoringPeriod: RosterForCurrentScoringPeriod?
  var adjustment: Int?
  var cumulativeScoreLive: CumulativeScoreLive?
  var cumulativeScore: CumulativeScore?
  var rosterForMatchupPeriodDelayed: RosterForMatchupPeriodDelayed?
  var tiebreak: Int?
  var totalPoints: Float?
  var totalPointsLive: Float?
  var teamId: Int?
  var pointsByScoringPeriod: PointsByScoringPeriod?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    rosterForCurrentScoringPeriod = try container.decodeIfPresent(RosterForCurrentScoringPeriod.self, forKey: .rosterForCurrentScoringPeriod)
    adjustment = try container.decodeIfPresent(Int.self, forKey: .adjustment)
    cumulativeScoreLive = try container.decodeIfPresent(CumulativeScoreLive.self, forKey: .cumulativeScoreLive)
    cumulativeScore = try container.decodeIfPresent(CumulativeScore.self, forKey: .cumulativeScore)
    rosterForMatchupPeriodDelayed = try container.decodeIfPresent(RosterForMatchupPeriodDelayed.self, forKey: .rosterForMatchupPeriodDelayed)
    tiebreak = try container.decodeIfPresent(Int.self, forKey: .tiebreak)
    totalPoints = try container.decodeIfPresent(Float.self, forKey: .totalPoints)
    totalPointsLive = try container.decodeIfPresent(Float.self, forKey: .totalPointsLive)
    teamId = try container.decodeIfPresent(Int.self, forKey: .teamId)
    pointsByScoringPeriod = try container.decodeIfPresent(PointsByScoringPeriod.self, forKey: .pointsByScoringPeriod)
  }

}
