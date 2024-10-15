//
//  PlayerPoolEntry.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct PlayerPoolEntry: Codable {

  enum CodingKeys: String, CodingKey {
    case player
    case id
  }

  var player: Player?
  var id: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    player = try container.decodeIfPresent(Player.self, forKey: .player)
    id = try container.decodeIfPresent(Int.self, forKey: .id)
  }

}
