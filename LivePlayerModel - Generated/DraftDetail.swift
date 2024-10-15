//
//  DraftDetail.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct DraftDetail: Codable {

  enum CodingKeys: String, CodingKey {
    case drafted
    case inProgress
  }

  var drafted: Bool?
  var inProgress: Bool?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    drafted = try container.decodeIfPresent(Bool.self, forKey: .drafted)
    inProgress = try container.decodeIfPresent(Bool.self, forKey: .inProgress)
  }

}
