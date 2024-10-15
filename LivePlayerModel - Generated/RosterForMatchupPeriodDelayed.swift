//
//  RosterForMatchupPeriodDelayed.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RosterForMatchupPeriodDelayed: Codable {

  enum CodingKeys: String, CodingKey {
    case entries
  }

  var entries: Any?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    entries = try container.decodeIfPresent([].self, forKey: .entries)
  }

}
