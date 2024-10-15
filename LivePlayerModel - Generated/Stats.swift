//
//  Stats.swift
//
//  Created by Gp. on 10/14/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct Stats: Codable {

  enum CodingKeys: String, CodingKey {
    case 20
    case 27
    case 219
    case 189
    case 158
    case 227
    case 156
    case 198
    case 118
    case 111
    case 57
    case 109
    case 233
    case 126
    case 11
    case 232
    case 16
    case 29
    case 75
    case 0
    case 115
    case 131
    case 184
    case 73
    case 41
    case 15
    case 28
    case 215
    case 62
    case 84
    case 82
    case 44
    case 175
    case 26
    case 89
    case 37
    case 122
    case 211
    case 135
    case 74
    case 213
    case 120
    case 49
    case 194
    case 112
    case 80
    case 45
    case 25
    case 88
    case 77
    case 192
    case 114
    case 104
    case 132
    case 97
    case 55
    case 63
    case 216
    case 94
    case 81
    case 43
    case 124
    case 130
    case 178
    case 133
    case 9
    case 5
    case 83
    case 225
    case 136
    case 117
    case 79
    case 113
    case 110
    case 30
    case 181
    case 61
    case 129
    case 128
    case 193
    case 103
    case 24
    case 85
    case 64
    case 70
    case 56
    case 183
    case 76
    case 125
    case 123
    case 196
    case 231
    case 134
    case 21
    case 220
    case 31
    case 67
    case 65
    case 179
    case 187
    case 223
    case 50
    case 107
    case 22
    case 69
    case 98
    case 10
    case 54
    case 96
    case 60
    case 42
    case 66
    case 224
    case 218
    case 72
    case 23
    case 14
    case 108
    case 106
    case 90
    case 36
    case 1
    case 195
    case 177
    case 119
    case 78
    case 87
    case 12
    case 199
    case 91
    case 86
    case 221
    case 17
    case 127
    case 234
    case 13
    case 4
    case 52
    case 212
    case 92
    case 229
    case 18
    case 47
    case 51
    case 40
    case 58
    case 101
    case 214
    case 68
    case 121
    case 71
    case 155
    case 19
    case 137
    case 48
    case 7
    case 222
    case 53
    case 188
    case 102
    case 6
    case 226
    case 2
    case 38
    case 116
    case 99
    case 3
    case 105
    case 59
    case 35
    case 191
    case 176
    case 230
    case 46
    case 185
    case 39
    case 100
    case 210
    case 93
    case 95
    case 200
    case 190
    case 33
    case 34
    case 8
    case 32
    case 217
  }

  var 20: Float?
  var 27: Int?
  var 219: Int?
  var 189: Int?
  var 158: Int?
  var 227: Int?
  var 156: Int?
  var 198: Int?
  var 118: Int?
  var 111: Int?
  var 57: Float?
  var 109: Int?
  var 233: Int?
  var 126: Float?
  var 11: Int?
  var 232: Int?
  var 16: Float?
  var 29: Int?
  var 75: Int?
  var 0: Int?
  var 115: Int?
  var 131: Int?
  var 184: Int?
  var 73: Float?
  var 41: Int?
  var 15: Int?
  var 28: Int?
  var 215: Float?
  var 62: Float?
  var 84: Int?
  var 82: Float?
  var 44: Float?
  var 175: Int?
  var 26: Float?
  var 89: Int?
  var 37: Float?
  var 122: Int?
  var 211: Int?
  var 135: Int?
  var 74: Int?
  var 213: Int?
  var 120: Int?
  var 49: Int?
  var 194: Int?
  var 112: Int?
  var 80: Int?
  var 45: Float?
  var 25: Int?
  var 88: Float?
  var 77: Int?
  var 192: Int?
  var 114: Float?
  var 104: Float?
  var 132: Int?
  var 97: Float?
  var 55: Int?
  var 63: Float?
  var 216: Int?
  var 94: Float?
  var 81: Int?
  var 43: Float?
  var 124: Int?
  var 130: Int?
  var 178: Int?
  var 133: Int?
  var 9: Int?
  var 5: Int?
  var 83: Int?
  var 225: Int?
  var 136: Int?
  var 117: Int?
  var 79: Float?
  var 113: Int?
  var 110: Int?
  var 30: Int?
  var 181: Int?
  var 61: Int?
  var 129: Int?
  var 128: Int?
  var 193: Int?
  var 103: Float?
  var 24: Int?
  var 85: Float?
  var 64: Int?
  var 70: Float?
  var 56: Float?
  var 183: Int?
  var 76: Float?
  var 125: Float?
  var 123: Int?
  var 196: Int?
  var 231: Int?
  var 134: Int?
  var 21: Int?
  var 220: Int?
  var 31: Int?
  var 67: Float?
  var 65: Int?
  var 179: Int?
  var 187: Int?
  var 223: Int?
  var 50: Int?
  var 107: Int?
  var 22: Int?
  var 69: Float?
  var 98: Float?
  var 10: Int?
  var 54: Int?
  var 96: Int?
  var 60: Float?
  var 42: Int?
  var 66: Float?
  var 224: Int?
  var 218: Int?
  var 72: Float?
  var 23: Int?
  var 14: Int?
  var 108: Int?
  var 106: Int?
  var 90: Int?
  var 36: Float?
  var 1: Int?
  var 195: Int?
  var 177: Int?
  var 119: Int?
  var 78: Int?
  var 87: Int?
  var 12: Int?
  var 199: Int?
  var 91: Int?
  var 86: Int?
  var 221: Int?
  var 17: Float?
  var 127: Int?
  var 234: Int?
  var 13: Int?
  var 4: Int?
  var 52: Int?
  var 212: Int?
  var 92: Int?
  var 229: Int?
  var 18: Float?
  var 47: Int?
  var 51: Int?
  var 40: Int?
  var 58: Int?
  var 101: Float?
  var 214: Int?
  var 68: Float?
  var 121: Int?
  var 71: Float?
  var 155: Int?
  var 19: Float?
  var 137: Float?
  var 48: Int?
  var 7: Int?
  var 222: Int?
  var 53: Int?
  var 188: Int?
  var 102: Float?
  var 6: Int?
  var 226: Int?
  var 2: Int?
  var 38: Float?
  var 116: Int?
  var 99: Int?
  var 3: Int?
  var 105: Float?
  var 59: Int?
  var 35: Float?
  var 191: Int?
  var 176: Int?
  var 230: Int?
  var 46: Float?
  var 185: Int?
  var 39: Int?
  var 100: Int?
  var 210: Int?
  var 93: Float?
  var 95: Int?
  var 200: Float?
  var 190: Int?
  var 33: Int?
  var 34: Int?
  var 8: Int?
  var 32: Int?
  var 217: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    20 = try container.decodeIfPresent(Float.self, forKey: .20)
    27 = try container.decodeIfPresent(Int.self, forKey: .27)
    219 = try container.decodeIfPresent(Int.self, forKey: .219)
    189 = try container.decodeIfPresent(Int.self, forKey: .189)
    158 = try container.decodeIfPresent(Int.self, forKey: .158)
    227 = try container.decodeIfPresent(Int.self, forKey: .227)
    156 = try container.decodeIfPresent(Int.self, forKey: .156)
    198 = try container.decodeIfPresent(Int.self, forKey: .198)
    118 = try container.decodeIfPresent(Int.self, forKey: .118)
    111 = try container.decodeIfPresent(Int.self, forKey: .111)
    57 = try container.decodeIfPresent(Float.self, forKey: .57)
    109 = try container.decodeIfPresent(Int.self, forKey: .109)
    233 = try container.decodeIfPresent(Int.self, forKey: .233)
    126 = try container.decodeIfPresent(Float.self, forKey: .126)
    11 = try container.decodeIfPresent(Int.self, forKey: .11)
    232 = try container.decodeIfPresent(Int.self, forKey: .232)
    16 = try container.decodeIfPresent(Float.self, forKey: .16)
    29 = try container.decodeIfPresent(Int.self, forKey: .29)
    75 = try container.decodeIfPresent(Int.self, forKey: .75)
    0 = try container.decodeIfPresent(Int.self, forKey: .0)
    115 = try container.decodeIfPresent(Int.self, forKey: .115)
    131 = try container.decodeIfPresent(Int.self, forKey: .131)
    184 = try container.decodeIfPresent(Int.self, forKey: .184)
    73 = try container.decodeIfPresent(Float.self, forKey: .73)
    41 = try container.decodeIfPresent(Int.self, forKey: .41)
    15 = try container.decodeIfPresent(Int.self, forKey: .15)
    28 = try container.decodeIfPresent(Int.self, forKey: .28)
    215 = try container.decodeIfPresent(Float.self, forKey: .215)
    62 = try container.decodeIfPresent(Float.self, forKey: .62)
    84 = try container.decodeIfPresent(Int.self, forKey: .84)
    82 = try container.decodeIfPresent(Float.self, forKey: .82)
    44 = try container.decodeIfPresent(Float.self, forKey: .44)
    175 = try container.decodeIfPresent(Int.self, forKey: .175)
    26 = try container.decodeIfPresent(Float.self, forKey: .26)
    89 = try container.decodeIfPresent(Int.self, forKey: .89)
    37 = try container.decodeIfPresent(Float.self, forKey: .37)
    122 = try container.decodeIfPresent(Int.self, forKey: .122)
    211 = try container.decodeIfPresent(Int.self, forKey: .211)
    135 = try container.decodeIfPresent(Int.self, forKey: .135)
    74 = try container.decodeIfPresent(Int.self, forKey: .74)
    213 = try container.decodeIfPresent(Int.self, forKey: .213)
    120 = try container.decodeIfPresent(Int.self, forKey: .120)
    49 = try container.decodeIfPresent(Int.self, forKey: .49)
    194 = try container.decodeIfPresent(Int.self, forKey: .194)
    112 = try container.decodeIfPresent(Int.self, forKey: .112)
    80 = try container.decodeIfPresent(Int.self, forKey: .80)
    45 = try container.decodeIfPresent(Float.self, forKey: .45)
    25 = try container.decodeIfPresent(Int.self, forKey: .25)
    88 = try container.decodeIfPresent(Float.self, forKey: .88)
    77 = try container.decodeIfPresent(Int.self, forKey: .77)
    192 = try container.decodeIfPresent(Int.self, forKey: .192)
    114 = try container.decodeIfPresent(Float.self, forKey: .114)
    104 = try container.decodeIfPresent(Float.self, forKey: .104)
    132 = try container.decodeIfPresent(Int.self, forKey: .132)
    97 = try container.decodeIfPresent(Float.self, forKey: .97)
    55 = try container.decodeIfPresent(Int.self, forKey: .55)
    63 = try container.decodeIfPresent(Float.self, forKey: .63)
    216 = try container.decodeIfPresent(Int.self, forKey: .216)
    94 = try container.decodeIfPresent(Float.self, forKey: .94)
    81 = try container.decodeIfPresent(Int.self, forKey: .81)
    43 = try container.decodeIfPresent(Float.self, forKey: .43)
    124 = try container.decodeIfPresent(Int.self, forKey: .124)
    130 = try container.decodeIfPresent(Int.self, forKey: .130)
    178 = try container.decodeIfPresent(Int.self, forKey: .178)
    133 = try container.decodeIfPresent(Int.self, forKey: .133)
    9 = try container.decodeIfPresent(Int.self, forKey: .9)
    5 = try container.decodeIfPresent(Int.self, forKey: .5)
    83 = try container.decodeIfPresent(Int.self, forKey: .83)
    225 = try container.decodeIfPresent(Int.self, forKey: .225)
    136 = try container.decodeIfPresent(Int.self, forKey: .136)
    117 = try container.decodeIfPresent(Int.self, forKey: .117)
    79 = try container.decodeIfPresent(Float.self, forKey: .79)
    113 = try container.decodeIfPresent(Int.self, forKey: .113)
    110 = try container.decodeIfPresent(Int.self, forKey: .110)
    30 = try container.decodeIfPresent(Int.self, forKey: .30)
    181 = try container.decodeIfPresent(Int.self, forKey: .181)
    61 = try container.decodeIfPresent(Int.self, forKey: .61)
    129 = try container.decodeIfPresent(Int.self, forKey: .129)
    128 = try container.decodeIfPresent(Int.self, forKey: .128)
    193 = try container.decodeIfPresent(Int.self, forKey: .193)
    103 = try container.decodeIfPresent(Float.self, forKey: .103)
    24 = try container.decodeIfPresent(Int.self, forKey: .24)
    85 = try container.decodeIfPresent(Float.self, forKey: .85)
    64 = try container.decodeIfPresent(Int.self, forKey: .64)
    70 = try container.decodeIfPresent(Float.self, forKey: .70)
    56 = try container.decodeIfPresent(Float.self, forKey: .56)
    183 = try container.decodeIfPresent(Int.self, forKey: .183)
    76 = try container.decodeIfPresent(Float.self, forKey: .76)
    125 = try container.decodeIfPresent(Float.self, forKey: .125)
    123 = try container.decodeIfPresent(Int.self, forKey: .123)
    196 = try container.decodeIfPresent(Int.self, forKey: .196)
    231 = try container.decodeIfPresent(Int.self, forKey: .231)
    134 = try container.decodeIfPresent(Int.self, forKey: .134)
    21 = try container.decodeIfPresent(Int.self, forKey: .21)
    220 = try container.decodeIfPresent(Int.self, forKey: .220)
    31 = try container.decodeIfPresent(Int.self, forKey: .31)
    67 = try container.decodeIfPresent(Float.self, forKey: .67)
    65 = try container.decodeIfPresent(Int.self, forKey: .65)
    179 = try container.decodeIfPresent(Int.self, forKey: .179)
    187 = try container.decodeIfPresent(Int.self, forKey: .187)
    223 = try container.decodeIfPresent(Int.self, forKey: .223)
    50 = try container.decodeIfPresent(Int.self, forKey: .50)
    107 = try container.decodeIfPresent(Int.self, forKey: .107)
    22 = try container.decodeIfPresent(Int.self, forKey: .22)
    69 = try container.decodeIfPresent(Float.self, forKey: .69)
    98 = try container.decodeIfPresent(Float.self, forKey: .98)
    10 = try container.decodeIfPresent(Int.self, forKey: .10)
    54 = try container.decodeIfPresent(Int.self, forKey: .54)
    96 = try container.decodeIfPresent(Int.self, forKey: .96)
    60 = try container.decodeIfPresent(Float.self, forKey: .60)
    42 = try container.decodeIfPresent(Int.self, forKey: .42)
    66 = try container.decodeIfPresent(Float.self, forKey: .66)
    224 = try container.decodeIfPresent(Int.self, forKey: .224)
    218 = try container.decodeIfPresent(Int.self, forKey: .218)
    72 = try container.decodeIfPresent(Float.self, forKey: .72)
    23 = try container.decodeIfPresent(Int.self, forKey: .23)
    14 = try container.decodeIfPresent(Int.self, forKey: .14)
    108 = try container.decodeIfPresent(Int.self, forKey: .108)
    106 = try container.decodeIfPresent(Int.self, forKey: .106)
    90 = try container.decodeIfPresent(Int.self, forKey: .90)
    36 = try container.decodeIfPresent(Float.self, forKey: .36)
    1 = try container.decodeIfPresent(Int.self, forKey: .1)
    195 = try container.decodeIfPresent(Int.self, forKey: .195)
    177 = try container.decodeIfPresent(Int.self, forKey: .177)
    119 = try container.decodeIfPresent(Int.self, forKey: .119)
    78 = try container.decodeIfPresent(Int.self, forKey: .78)
    87 = try container.decodeIfPresent(Int.self, forKey: .87)
    12 = try container.decodeIfPresent(Int.self, forKey: .12)
    199 = try container.decodeIfPresent(Int.self, forKey: .199)
    91 = try container.decodeIfPresent(Int.self, forKey: .91)
    86 = try container.decodeIfPresent(Int.self, forKey: .86)
    221 = try container.decodeIfPresent(Int.self, forKey: .221)
    17 = try container.decodeIfPresent(Float.self, forKey: .17)
    127 = try container.decodeIfPresent(Int.self, forKey: .127)
    234 = try container.decodeIfPresent(Int.self, forKey: .234)
    13 = try container.decodeIfPresent(Int.self, forKey: .13)
    4 = try container.decodeIfPresent(Int.self, forKey: .4)
    52 = try container.decodeIfPresent(Int.self, forKey: .52)
    212 = try container.decodeIfPresent(Int.self, forKey: .212)
    92 = try container.decodeIfPresent(Int.self, forKey: .92)
    229 = try container.decodeIfPresent(Int.self, forKey: .229)
    18 = try container.decodeIfPresent(Float.self, forKey: .18)
    47 = try container.decodeIfPresent(Int.self, forKey: .47)
    51 = try container.decodeIfPresent(Int.self, forKey: .51)
    40 = try container.decodeIfPresent(Int.self, forKey: .40)
    58 = try container.decodeIfPresent(Int.self, forKey: .58)
    101 = try container.decodeIfPresent(Float.self, forKey: .101)
    214 = try container.decodeIfPresent(Int.self, forKey: .214)
    68 = try container.decodeIfPresent(Float.self, forKey: .68)
    121 = try container.decodeIfPresent(Int.self, forKey: .121)
    71 = try container.decodeIfPresent(Float.self, forKey: .71)
    155 = try container.decodeIfPresent(Int.self, forKey: .155)
    19 = try container.decodeIfPresent(Float.self, forKey: .19)
    137 = try container.decodeIfPresent(Float.self, forKey: .137)
    48 = try container.decodeIfPresent(Int.self, forKey: .48)
    7 = try container.decodeIfPresent(Int.self, forKey: .7)
    222 = try container.decodeIfPresent(Int.self, forKey: .222)
    53 = try container.decodeIfPresent(Int.self, forKey: .53)
    188 = try container.decodeIfPresent(Int.self, forKey: .188)
    102 = try container.decodeIfPresent(Float.self, forKey: .102)
    6 = try container.decodeIfPresent(Int.self, forKey: .6)
    226 = try container.decodeIfPresent(Int.self, forKey: .226)
    2 = try container.decodeIfPresent(Int.self, forKey: .2)
    38 = try container.decodeIfPresent(Float.self, forKey: .38)
    116 = try container.decodeIfPresent(Int.self, forKey: .116)
    99 = try container.decodeIfPresent(Int.self, forKey: .99)
    3 = try container.decodeIfPresent(Int.self, forKey: .3)
    105 = try container.decodeIfPresent(Float.self, forKey: .105)
    59 = try container.decodeIfPresent(Int.self, forKey: .59)
    35 = try container.decodeIfPresent(Float.self, forKey: .35)
    191 = try container.decodeIfPresent(Int.self, forKey: .191)
    176 = try container.decodeIfPresent(Int.self, forKey: .176)
    230 = try container.decodeIfPresent(Int.self, forKey: .230)
    46 = try container.decodeIfPresent(Float.self, forKey: .46)
    185 = try container.decodeIfPresent(Int.self, forKey: .185)
    39 = try container.decodeIfPresent(Int.self, forKey: .39)
    100 = try container.decodeIfPresent(Int.self, forKey: .100)
    210 = try container.decodeIfPresent(Int.self, forKey: .210)
    93 = try container.decodeIfPresent(Float.self, forKey: .93)
    95 = try container.decodeIfPresent(Int.self, forKey: .95)
    200 = try container.decodeIfPresent(Float.self, forKey: .200)
    190 = try container.decodeIfPresent(Int.self, forKey: .190)
    33 = try container.decodeIfPresent(Int.self, forKey: .33)
    34 = try container.decodeIfPresent(Int.self, forKey: .34)
    8 = try container.decodeIfPresent(Int.self, forKey: .8)
    32 = try container.decodeIfPresent(Int.self, forKey: .32)
    217 = try container.decodeIfPresent(Int.self, forKey: .217)
  }

}
