//
//  RosterForCurrentScoringPeriod.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RosterForCurrentScoringPeriod: Codable {

  enum CodingKeys: String, CodingKey {
    case appliedStatTotal
    case entries
  }

  var appliedStatTotal: Float?
  var entries: [Entries]?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    appliedStatTotal = try container.decodeIfPresent(Float.self, forKey: .appliedStatTotal)
    entries = try container.decodeIfPresent([Entries].self, forKey: .entries)
  }

}
