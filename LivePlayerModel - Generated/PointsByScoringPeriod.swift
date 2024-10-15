//
//  PointsByScoringPeriod.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct PointsByScoringPeriod: Codable {

  enum CodingKeys: String, CodingKey {
    case 3
    case 2
    case 4
    case 5
    case 6
    case 1
  }

  var 3: Float?
  var 2: Float?
  var 4: Float?
  var 5: Float?
  var 6: Float?
  var 1: Float?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    3 = try container.decodeIfPresent(Float.self, forKey: .3)
    2 = try container.decodeIfPresent(Float.self, forKey: .2)
    4 = try container.decodeIfPresent(Float.self, forKey: .4)
    5 = try container.decodeIfPresent(Float.self, forKey: .5)
    6 = try container.decodeIfPresent(Float.self, forKey: .6)
    1 = try container.decodeIfPresent(Float.self, forKey: .1)
  }

}
