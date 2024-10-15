//
//  AppliedStats.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct AppliedStats: Codable {

  enum CodingKeys: String, CodingKey {
    case 19
    case 92
    case 98
    case 101
    case 25
    case 129
    case 77
    case 123
    case 124
    case 133
    case 103
    case 44
    case 99
    case 53
    case 43
    case 20
    case 130
    case 102
    case 63
    case 24
    case 3
    case 135
    case 91
    case 4
    case 134
    case 90
    case 104
    case 97
    case 72
    case 89
    case 96
    case 85
    case 198
    case 132
    case 42
    case 80
    case 128
    case 136
    case 86
    case 125
    case 26
    case 95
    case 93
  }

  var 19: Float?
  var 92: Int?
  var 98: Float?
  var 101: Float?
  var 25: Int?
  var 129: Int?
  var 77: Int?
  var 123: Int?
  var 124: Int?
  var 133: Int?
  var 103: Float?
  var 44: Float?
  var 99: Int?
  var 53: Int?
  var 43: Float?
  var 20: Float?
  var 130: Int?
  var 102: Float?
  var 63: Float?
  var 24: Float?
  var 3: Float?
  var 135: Int?
  var 91: Int?
  var 4: Int?
  var 134: Int?
  var 90: Int?
  var 104: Float?
  var 97: Float?
  var 72: Float?
  var 89: Int?
  var 96: Int?
  var 85: Float?
  var 198: Int?
  var 132: Int?
  var 42: Float?
  var 80: Int?
  var 128: Int?
  var 136: Int?
  var 86: Int?
  var 125: Float?
  var 26: Float?
  var 95: Int?
  var 93: Float?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    19 = try container.decodeIfPresent(Float.self, forKey: .19)
    92 = try container.decodeIfPresent(Int.self, forKey: .92)
    98 = try container.decodeIfPresent(Float.self, forKey: .98)
    101 = try container.decodeIfPresent(Float.self, forKey: .101)
    25 = try container.decodeIfPresent(Int.self, forKey: .25)
    129 = try container.decodeIfPresent(Int.self, forKey: .129)
    77 = try container.decodeIfPresent(Int.self, forKey: .77)
    123 = try container.decodeIfPresent(Int.self, forKey: .123)
    124 = try container.decodeIfPresent(Int.self, forKey: .124)
    133 = try container.decodeIfPresent(Int.self, forKey: .133)
    103 = try container.decodeIfPresent(Float.self, forKey: .103)
    44 = try container.decodeIfPresent(Float.self, forKey: .44)
    99 = try container.decodeIfPresent(Int.self, forKey: .99)
    53 = try container.decodeIfPresent(Int.self, forKey: .53)
    43 = try container.decodeIfPresent(Float.self, forKey: .43)
    20 = try container.decodeIfPresent(Float.self, forKey: .20)
    130 = try container.decodeIfPresent(Int.self, forKey: .130)
    102 = try container.decodeIfPresent(Float.self, forKey: .102)
    63 = try container.decodeIfPresent(Float.self, forKey: .63)
    24 = try container.decodeIfPresent(Float.self, forKey: .24)
    3 = try container.decodeIfPresent(Float.self, forKey: .3)
    135 = try container.decodeIfPresent(Int.self, forKey: .135)
    91 = try container.decodeIfPresent(Int.self, forKey: .91)
    4 = try container.decodeIfPresent(Int.self, forKey: .4)
    134 = try container.decodeIfPresent(Int.self, forKey: .134)
    90 = try container.decodeIfPresent(Int.self, forKey: .90)
    104 = try container.decodeIfPresent(Float.self, forKey: .104)
    97 = try container.decodeIfPresent(Float.self, forKey: .97)
    72 = try container.decodeIfPresent(Float.self, forKey: .72)
    89 = try container.decodeIfPresent(Int.self, forKey: .89)
    96 = try container.decodeIfPresent(Int.self, forKey: .96)
    85 = try container.decodeIfPresent(Float.self, forKey: .85)
    198 = try container.decodeIfPresent(Int.self, forKey: .198)
    132 = try container.decodeIfPresent(Int.self, forKey: .132)
    42 = try container.decodeIfPresent(Float.self, forKey: .42)
    80 = try container.decodeIfPresent(Int.self, forKey: .80)
    128 = try container.decodeIfPresent(Int.self, forKey: .128)
    136 = try container.decodeIfPresent(Int.self, forKey: .136)
    86 = try container.decodeIfPresent(Int.self, forKey: .86)
    125 = try container.decodeIfPresent(Float.self, forKey: .125)
    26 = try container.decodeIfPresent(Float.self, forKey: .26)
    95 = try container.decodeIfPresent(Int.self, forKey: .95)
    93 = try container.decodeIfPresent(Float.self, forKey: .93)
  }

}
