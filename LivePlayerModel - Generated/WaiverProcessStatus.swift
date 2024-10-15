//
//  WaiverProcessStatus.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct WaiverProcessStatus: Codable {

  enum CodingKeys: String, CodingKey {
    case 519+0000 = "2024-09-11T07:46:53.519+0000"
    case 216+0000 = "2024-10-06T08:12:15.216+0000"
    case 273+0000 = "2024-09-25T07:02:19.273+0000"
    case 509+0000 = "2024-10-09T07:17:34.509+0000"
    case 400+0000 = "2024-09-18T07:44:34.400+0000"
    case 725+0000 = "2024-10-02T08:24:26.725+0000"
  }

  var 20240911T07:46:53.519+0000: Int?
  var 20241006T08:12:15.216+0000: Int?
  var 20240925T07:02:19.273+0000: Int?
  var 20241009T07:17:34.509+0000: Int?
  var 20240918T07:44:34.400+0000: Int?
  var 20241002T08:24:26.725+0000: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    20240911T07:46:53.519+0000 = try container.decodeIfPresent(Int.self, forKey: .519+0000)
    20241006T08:12:15.216+0000 = try container.decodeIfPresent(Int.self, forKey: .216+0000)
    20240925T07:02:19.273+0000 = try container.decodeIfPresent(Int.self, forKey: .273+0000)
    20241009T07:17:34.509+0000 = try container.decodeIfPresent(Int.self, forKey: .509+0000)
    20240918T07:44:34.400+0000 = try container.decodeIfPresent(Int.self, forKey: .400+0000)
    20241002T08:24:26.725+0000 = try container.decodeIfPresent(Int.self, forKey: .725+0000)
  }

}
