//
//  Schedule.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct Schedule: Codable {

  enum CodingKeys: String, CodingKey {
    case matchupPeriodId
    case away
    case playoffTierType
    case id
    case home
    case winner
  }

  var matchupPeriodId: Int?
  var away: Away?
  var playoffTierType: String?
  var id: Int?
  var home: Home?
  var winner: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    matchupPeriodId = try container.decodeIfPresent(Int.self, forKey: .matchupPeriodId)
    away = try container.decodeIfPresent(Away.self, forKey: .away)
    playoffTierType = try container.decodeIfPresent(String.self, forKey: .playoffTierType)
    id = try container.decodeIfPresent(Int.self, forKey: .id)
    home = try container.decodeIfPresent(Home.self, forKey: .home)
    winner = try container.decodeIfPresent(String.self, forKey: .winner)
  }

}
