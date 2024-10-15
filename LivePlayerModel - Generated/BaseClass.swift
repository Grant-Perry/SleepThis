//
//  BaseClass.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct BaseClass: Codable {

  enum CodingKeys: String, CodingKey {
    case segmentId
    case schedule
    case seasonId
    case gameId
    case draftDetail
    case scoringPeriodId
    case status
    case id
  }

  var segmentId: Int?
  var schedule: [Schedule]?
  var seasonId: Int?
  var gameId: Int?
  var draftDetail: DraftDetail?
  var scoringPeriodId: Int?
  var status: Status?
  var id: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    segmentId = try container.decodeIfPresent(Int.self, forKey: .segmentId)
    schedule = try container.decodeIfPresent([Schedule].self, forKey: .schedule)
    seasonId = try container.decodeIfPresent(Int.self, forKey: .seasonId)
    gameId = try container.decodeIfPresent(Int.self, forKey: .gameId)
    draftDetail = try container.decodeIfPresent(DraftDetail.self, forKey: .draftDetail)
    scoringPeriodId = try container.decodeIfPresent(Int.self, forKey: .scoringPeriodId)
    status = try container.decodeIfPresent(Status.self, forKey: .status)
    id = try container.decodeIfPresent(Int.self, forKey: .id)
  }

}
