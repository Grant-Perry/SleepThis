//
//  Status.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct Status: Codable {

  enum CodingKeys: String, CodingKey {
    case standingsUpdateDate
    case teamsJoined
    case isExpired
    case currentMatchupPeriod
    case isActive
    case transactionScoringPeriod
    case firstScoringPeriod
    case activatedDate
    case finalScoringPeriod
    case isFull
    case previousSeasons
    case waiverProcessStatus
    case isViewable
    case isToBeDeleted
    case createdAsLeagueType
    case isPlayoffMatchupEdited
    case currentLeagueType
    case waiverLastExecutionDate
    case latestScoringPeriod
    case isWaiverOrderEdited
  }

  var standingsUpdateDate: Int?
  var teamsJoined: Int?
  var isExpired: Bool?
  var currentMatchupPeriod: Int?
  var isActive: Bool?
  var transactionScoringPeriod: Int?
  var firstScoringPeriod: Int?
  var activatedDate: Int?
  var finalScoringPeriod: Int?
  var isFull: Bool?
  var previousSeasons: [Int]?
  var waiverProcessStatus: WaiverProcessStatus?
  var isViewable: Bool?
  var isToBeDeleted: Bool?
  var createdAsLeagueType: Int?
  var isPlayoffMatchupEdited: Bool?
  var currentLeagueType: Int?
  var waiverLastExecutionDate: Int?
  var latestScoringPeriod: Int?
  var isWaiverOrderEdited: Bool?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    standingsUpdateDate = try container.decodeIfPresent(Int.self, forKey: .standingsUpdateDate)
    teamsJoined = try container.decodeIfPresent(Int.self, forKey: .teamsJoined)
    isExpired = try container.decodeIfPresent(Bool.self, forKey: .isExpired)
    currentMatchupPeriod = try container.decodeIfPresent(Int.self, forKey: .currentMatchupPeriod)
    isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive)
    transactionScoringPeriod = try container.decodeIfPresent(Int.self, forKey: .transactionScoringPeriod)
    firstScoringPeriod = try container.decodeIfPresent(Int.self, forKey: .firstScoringPeriod)
    activatedDate = try container.decodeIfPresent(Int.self, forKey: .activatedDate)
    finalScoringPeriod = try container.decodeIfPresent(Int.self, forKey: .finalScoringPeriod)
    isFull = try container.decodeIfPresent(Bool.self, forKey: .isFull)
    previousSeasons = try container.decodeIfPresent([Int].self, forKey: .previousSeasons)
    waiverProcessStatus = try container.decodeIfPresent(WaiverProcessStatus.self, forKey: .waiverProcessStatus)
    isViewable = try container.decodeIfPresent(Bool.self, forKey: .isViewable)
    isToBeDeleted = try container.decodeIfPresent(Bool.self, forKey: .isToBeDeleted)
    createdAsLeagueType = try container.decodeIfPresent(Int.self, forKey: .createdAsLeagueType)
    isPlayoffMatchupEdited = try container.decodeIfPresent(Bool.self, forKey: .isPlayoffMatchupEdited)
    currentLeagueType = try container.decodeIfPresent(Int.self, forKey: .currentLeagueType)
    waiverLastExecutionDate = try container.decodeIfPresent(Int.self, forKey: .waiverLastExecutionDate)
    latestScoringPeriod = try container.decodeIfPresent(Int.self, forKey: .latestScoringPeriod)
    isWaiverOrderEdited = try container.decodeIfPresent(Bool.self, forKey: .isWaiverOrderEdited)
  }

}
