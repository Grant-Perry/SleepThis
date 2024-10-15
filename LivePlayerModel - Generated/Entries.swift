//
//  Entries.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct Entries: Codable {

  enum CodingKeys: String, CodingKey {
    case playerPoolEntry
    case lineupSlotId
    case playerId
  }

  var playerPoolEntry: PlayerPoolEntry?
  var lineupSlotId: Int?
  var playerId: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    playerPoolEntry = try container.decodeIfPresent(PlayerPoolEntry.self, forKey: .playerPoolEntry)
    lineupSlotId = try container.decodeIfPresent(Int.self, forKey: .lineupSlotId)
    playerId = try container.decodeIfPresent(Int.self, forKey: .playerId)
  }

}
