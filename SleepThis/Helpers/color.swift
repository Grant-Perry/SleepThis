//
//  Color+Ext.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/3/23.
//

import SwiftUI

extension Color {

   static let gpBlue = Color(#colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1))
   static let gpBlue2 = Color(#colorLiteral(red: 0.2789276042, green: 0.5103674376, blue: 0.6088686343, alpha: 1))
   static let gpGreen = Color(#colorLiteral(red: 0.3911147745, green: 0.8800172018, blue: 0.2343971767, alpha: 1))
   static let gpMinty = Color(#colorLiteral(red: 0.5960784314, green: 1, blue: 0.5960784314, alpha: 1))
   static let gpGray = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
   static let gpArmyGreen = Color(#colorLiteral(red: 0.4392156863, green: 0.4352941176, blue: 0.1803921569, alpha: 1))
   static let gpOrange = Color(#colorLiteral(red: 1, green: 0.6470588235, blue: 0, alpha: 1))
   static let gpPink = Color(#colorLiteral(red: 1, green: 0.4117647059, blue: 0.7058823529, alpha: 1))
   static let gpPurple = Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
   static let gpRed = Color(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
   static let gpRedLight = Color(#colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1))
   static let gpRedPink = Color(#colorLiteral(red: 1, green: 0.1857388616, blue: 0.3251032516, alpha: 1))
   static let gpYellowD = Color(#colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1))
   static let gpYellow = Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))
   static let gpDeltaPurple = Color(#colorLiteral(red: 0.5450980392, green: 0.1019607843, blue: 0.2901960784, alpha: 1))
   static let gpMaroon = Color(#colorLiteral(red: 0.4392156863, green: 0.1803921569, blue: 0.3137254902, alpha: 1))
   static let gpBlueDark = Color(#colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1))
   static let gpBlueDarkL = Color(#colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1))
   static let gpBlueLight = Color(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1))
   static let gpWhite = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))

   static let gpUndrafted = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))


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

   static let mBG1 = Color(rgb: 70, 189, 198)
   static let mBG2 = Color(rgb: 66, 133, 244)
   static let mBG3 = Color(rgb: 249, 203, 156)
   static let mBG4 = Color(rgb: 255, 0, 255)
   static let mBG5 = Color(rgb: 164, 205, 208)
   static let mBG6 = Color(rgb: 230, 145, 56)
   static let mBG7 = Color(rgb: 166, 77, 121)
   static let mBG8 = Color(rgb: 241, 194, 50)
   static let mBG9 = Color(rgb: 0, 255, 255)
   static let mBG10 = Color(rgb: 255, 109, 1)
   static let mBG11 = Color(rgb: 0, 255, 0)
   static let mBG12 = Color(rgb: 255, 255, 0)

   func lighter(by percentage: CGFloat = 0.05) -> Color {
	  return self.adjustBrightness(by: abs(percentage))
   }

   func adjustBrightness(by percentage: CGFloat) -> Color {
	  var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
	  UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)

	  return Color(
		 red: min(r + percentage, 1.0),
		 green: min(g + percentage, 1.0),
		 blue: min(b + percentage, 1.0),
		 opacity: Double(a)
	  )
   }

   func blended(withFraction fraction: CGFloat, of color: Color) -> Color {
	  let uiColor1 = UIColor(self)
	  let uiColor2 = UIColor(color)
	  var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
	  var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

	  uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
	  uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

	  return Color(
		 red: r1 + (r2 - r1) * fraction,
		 green: g1 + (g2 - g1) * fraction,
		 blue: b1 + (b2 - b1) * fraction,
		 opacity: a1 + (a2 - a1) * fraction
	  )
   }


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

extension Color {
   // Convert a hex string to a SwiftUI Color
   init(hex: String) {
	  let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
	  var int: UInt64 = 0
	  Scanner(string: hex).scanHexInt64(&int)
	  let a, r, g, b: UInt64
	  switch hex.count {
		 case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		 case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		 case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		 default:
			(a, r, g, b) = (255, 0, 0, 0)
	  }

	  self.init(
		 .sRGB,
		 red: Double(r) / 255,
		 green: Double(g) / 255,
		 blue: Double(b) / 255,
		 opacity: Double(a) / 255
	  )
   }
}


