//
//  Color+Ext.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/3/23.
//

import SwiftUI

extension Color {

   static let gpBlue = Color(#colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1))
   static let gpGreen = Color(#colorLiteral(red: 0.3911147745, green: 0.8800172018, blue: 0.2343971767, alpha: 1))
   static let gpMinty = Color(#colorLiteral(red: 0.5960784314, green: 1, blue: 0.5960784314, alpha: 1))
   static let gpArmyGreen = Color(#colorLiteral(red: 0.4392156863, green: 0.4352941176, blue: 0.1803921569, alpha: 1))
   static let gpOrange = Color(#colorLiteral(red: 1, green: 0.6470588235, blue: 0, alpha: 1))
   static let gpPink = Color(#colorLiteral(red: 1, green: 0.4117647059, blue: 0.7058823529, alpha: 1))
   static let gpPurple = Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
   static let gpRed = Color(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
   static let gpRedPink = Color(#colorLiteral(red: 1, green: 0.1857388616, blue: 0.3251032516, alpha: 1))
   static let gpYellowD = Color(#colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1))
   static let gpYellow = Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))
   static let gpDeltaPurple = Color(#colorLiteral(red: 0.5450980392, green: 0.1019607843, blue: 0.2901960784, alpha: 1))
   static let gpMaroon = Color(#colorLiteral(red: 0.4392156863, green: 0.1803921569, blue: 0.3137254902, alpha: 1))
   static let gpBlueDark = Color(#colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1))
   static let gpBlueDarkL = Color(#colorLiteral(red: 0.08346207272, green: 0.1920862778, blue: 0.2470588237, alpha: 1))
   static let gpBlueLight = Color(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1))

   static let gpDark1 = Color(#colorLiteral(red: 0.1378855407, green: 0.1486340761, blue: 0.1635932028, alpha: 1))
   static let gpDark2 = Color(#colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1))
   
   static let gpPostTop = Color(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1))
   static let gpPostBot = Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1))

   static let gpCurrentTop = Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
   static let gpCurrentBot = Color(#colorLiteral(red: 0.3128006691, green: 0.4008095726, blue: 0.6235075593, alpha: 1))

   static let gpScheduledTop = Color(#colorLiteral(red: 0.3156160096, green: 0.6235294342, blue: 0.5034397076, alpha: 1))
   static let gpScheduledBot = Color(#colorLiteral(red: 0.03852885208, green: 0.6235294342, blue: 0.3622174664, alpha: 1))

   static let gpFinalTop = Color(#colorLiteral(red: 0.4196078431, green: 0.2901960784, blue: 0.4745098039, alpha: 1))
   static let gpFinalBot = Color(#colorLiteral(red: 0.768627451, green: 0.6078431373, blue: 0.8588235294, alpha: 1))

   static let mBG1 = Color(rgb: 255, 255, 4)   // #FFFF04
   static let mBG2 = Color(rgb: 1, 255, 0)     // #01FF00
   static let mBG3 = Color(rgb: 255, 109, 0)   // #FF6D00
   static let mBG4 = Color(rgb: 1, 255, 255)   // #01FFFF
   static let mBG5 = Color(rgb: 241, 194, 51)  // #F1C233
   static let mBG6 = Color(rgb: 166, 77, 121)  // #A64D79
   static let mBG7 = Color(rgb: 230, 145, 56)  // #E69138
   static let mBG8 = Color(rgb: 163, 205, 208) // #A3CDD0
   static let mBG9 = Color(rgb: 255, 0, 255)   // #FF00FF
   static let mBG10 = Color(rgb: 249, 203, 156) // #F9CB9C
   static let mBG11 = Color(rgb: 65, 133, 244) // #4185F4
   static let mBG12 = Color(rgb: 70, 189, 198) // #46BDC6


}

// UTILIZATION: Color(rgb: 220, 123, 35)
extension Color {
   init(rgb: Int...) {
	  if rgb.count == 3 {
		 self.init(red: Double(rgb[0]) / 255.0, green: Double(rgb[1]) / 255.0, blue: Double(rgb[2]) / 255.0)
	  } else {
		 self.init(red: 1.0, green: 0.5, blue: 1.0)
	  }
   }
}
