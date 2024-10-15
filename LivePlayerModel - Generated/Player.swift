//
//  Player.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct Player: Codable {

  enum CodingKeys: String, CodingKey {
    case fullName
    case proTeamId
    case stats
    case universeId
    case defaultPositionId
    case id
  }

  var fullName: String?
  var proTeamId: Int?
  var stats: [Stats]?
  var universeId: Int?
  var defaultPositionId: Int?
  var id: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
    proTeamId = try container.decodeIfPresent(Int.self, forKey: .proTeamId)
    stats = try container.decodeIfPresent([Stats].self, forKey: .stats)
    universeId = try container.decodeIfPresent(Int.self, forKey: .universeId)
    defaultPositionId = try container.decodeIfPresent(Int.self, forKey: .defaultPositionId)
    id = try container.decodeIfPresent(Int.self, forKey: .id)
  }

}
