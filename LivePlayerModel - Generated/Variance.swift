//
//  Variance.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct Variance: Codable {

  enum CodingKeys: String, CodingKey {
    case 99
    case 74
    case 106
    case 113
    case 81
    case 19
    case 42
    case 0
    case 78
    case 127
    case 103
    case 97
    case 104
    case 1
    case 15
    case 26
    case 87
    case 45
    case 36
    case 72
    case 4
    case 86
    case 80
    case 53
    case 20
    case 43
    case 83
    case 98
    case 63
    case 84
    case 115
    case 58
    case 3
    case 76
    case 82
    case 114
    case 200
    case 77
    case 85
    case 16
    case 94
    case 23
    case 24
    case 75
    case 25
    case 96
    case 93
    case 79
    case 120
    case 44
    case 88
    case 198
    case 46
    case 68
    case 35
    case 95
    case 102
    case 64
    case 199
    case 101
  }

  var 99: Float?
  var 74: Float?
  var 106: Float?
  var 113: Float?
  var 81: Float?
  var 19: Float?
  var 42: Float?
  var 0: Float?
  var 78: Float?
  var 127: Float?
  var 103: Float?
  var 97: Float?
  var 104: Float?
  var 1: Float?
  var 15: Float?
  var 26: Float?
  var 87: Float?
  var 45: Float?
  var 36: Float?
  var 72: Float?
  var 4: Float?
  var 86: Float?
  var 80: Float?
  var 53: Float?
  var 20: Float?
  var 43: Float?
  var 83: Float?
  var 98: Float?
  var 63: Float?
  var 84: Float?
  var 115: Float?
  var 58: Float?
  var 3: Float?
  var 76: Float?
  var 82: Float?
  var 114: Float?
  var 200: Float?
  var 77: Float?
  var 85: Float?
  var 16: Float?
  var 94: Float?
  var 23: Float?
  var 24: Float?
  var 75: Float?
  var 25: Float?
  var 96: Float?
  var 93: Float?
  var 79: Float?
  var 120: Float?
  var 44: Float?
  var 88: Float?
  var 198: Float?
  var 46: Float?
  var 68: Float?
  var 35: Float?
  var 95: Float?
  var 102: Float?
  var 64: Float?
  var 199: Float?
  var 101: Float?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    99 = try container.decodeIfPresent(Float.self, forKey: .99)
    74 = try container.decodeIfPresent(Float.self, forKey: .74)
    106 = try container.decodeIfPresent(Float.self, forKey: .106)
    113 = try container.decodeIfPresent(Float.self, forKey: .113)
    81 = try container.decodeIfPresent(Float.self, forKey: .81)
    19 = try container.decodeIfPresent(Float.self, forKey: .19)
    42 = try container.decodeIfPresent(Float.self, forKey: .42)
    0 = try container.decodeIfPresent(Float.self, forKey: .0)
    78 = try container.decodeIfPresent(Float.self, forKey: .78)
    127 = try container.decodeIfPresent(Float.self, forKey: .127)
    103 = try container.decodeIfPresent(Float.self, forKey: .103)
    97 = try container.decodeIfPresent(Float.self, forKey: .97)
    104 = try container.decodeIfPresent(Float.self, forKey: .104)
    1 = try container.decodeIfPresent(Float.self, forKey: .1)
    15 = try container.decodeIfPresent(Float.self, forKey: .15)
    26 = try container.decodeIfPresent(Float.self, forKey: .26)
    87 = try container.decodeIfPresent(Float.self, forKey: .87)
    45 = try container.decodeIfPresent(Float.self, forKey: .45)
    36 = try container.decodeIfPresent(Float.self, forKey: .36)
    72 = try container.decodeIfPresent(Float.self, forKey: .72)
    4 = try container.decodeIfPresent(Float.self, forKey: .4)
    86 = try container.decodeIfPresent(Float.self, forKey: .86)
    80 = try container.decodeIfPresent(Float.self, forKey: .80)
    53 = try container.decodeIfPresent(Float.self, forKey: .53)
    20 = try container.decodeIfPresent(Float.self, forKey: .20)
    43 = try container.decodeIfPresent(Float.self, forKey: .43)
    83 = try container.decodeIfPresent(Float.self, forKey: .83)
    98 = try container.decodeIfPresent(Float.self, forKey: .98)
    63 = try container.decodeIfPresent(Float.self, forKey: .63)
    84 = try container.decodeIfPresent(Float.self, forKey: .84)
    115 = try container.decodeIfPresent(Float.self, forKey: .115)
    58 = try container.decodeIfPresent(Float.self, forKey: .58)
    3 = try container.decodeIfPresent(Float.self, forKey: .3)
    76 = try container.decodeIfPresent(Float.self, forKey: .76)
    82 = try container.decodeIfPresent(Float.self, forKey: .82)
    114 = try container.decodeIfPresent(Float.self, forKey: .114)
    200 = try container.decodeIfPresent(Float.self, forKey: .200)
    77 = try container.decodeIfPresent(Float.self, forKey: .77)
    85 = try container.decodeIfPresent(Float.self, forKey: .85)
    16 = try container.decodeIfPresent(Float.self, forKey: .16)
    94 = try container.decodeIfPresent(Float.self, forKey: .94)
    23 = try container.decodeIfPresent(Float.self, forKey: .23)
    24 = try container.decodeIfPresent(Float.self, forKey: .24)
    75 = try container.decodeIfPresent(Float.self, forKey: .75)
    25 = try container.decodeIfPresent(Float.self, forKey: .25)
    96 = try container.decodeIfPresent(Float.self, forKey: .96)
    93 = try container.decodeIfPresent(Float.self, forKey: .93)
    79 = try container.decodeIfPresent(Float.self, forKey: .79)
    120 = try container.decodeIfPresent(Float.self, forKey: .120)
    44 = try container.decodeIfPresent(Float.self, forKey: .44)
    88 = try container.decodeIfPresent(Float.self, forKey: .88)
    198 = try container.decodeIfPresent(Float.self, forKey: .198)
    46 = try container.decodeIfPresent(Float.self, forKey: .46)
    68 = try container.decodeIfPresent(Float.self, forKey: .68)
    35 = try container.decodeIfPresent(Float.self, forKey: .35)
    95 = try container.decodeIfPresent(Float.self, forKey: .95)
    102 = try container.decodeIfPresent(Float.self, forKey: .102)
    64 = try container.decodeIfPresent(Float.self, forKey: .64)
    199 = try container.decodeIfPresent(Float.self, forKey: .199)
    101 = try container.decodeIfPresent(Float.self, forKey: .101)
  }

}
