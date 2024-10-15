//
//  CumulativeScore.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct CumulativeScore: Codable {

  enum CodingKeys: String, CodingKey {
    case losses
    case ties
    case wins
  }

  var losses: Int?
  var ties: Int?
  var wins: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    losses = try container.decodeIfPresent(Int.self, forKey: .losses)
    ties = try container.decodeIfPresent(Int.self, forKey: .ties)
    wins = try container.decodeIfPresent(Int.self, forKey: .wins)
  }

}
