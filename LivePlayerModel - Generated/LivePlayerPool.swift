//
//  LivePlayerPool.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct LivePlayerPool: Codable {

  enum CodingKeys: String, CodingKey {
    case status
    case scoringPeriodId
    case segmentId
    case schedule
    case seasonId
    case draftDetail
    case gameId
    case id
  }

  var status: Status?
  var scoringPeriodId: Int?
  var segmentId: Int?
  var schedule: [Schedule]?
  var seasonId: Int?
  var draftDetail: DraftDetail?
  var gameId: Int?
  var id: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    status = try container.decodeIfPresent(Status.self, forKey: .status)
    scoringPeriodId = try container.decodeIfPresent(Int.self, forKey: .scoringPeriodId)
    segmentId = try container.decodeIfPresent(Int.self, forKey: .segmentId)
    schedule = try container.decodeIfPresent([Schedule].self, forKey: .schedule)
    seasonId = try container.decodeIfPresent(Int.self, forKey: .seasonId)
    draftDetail = try container.decodeIfPresent(DraftDetail.self, forKey: .draftDetail)
    gameId = try container.decodeIfPresent(Int.self, forKey: .gameId)
    id = try container.decodeIfPresent(Int.self, forKey: .id)
  }

}
