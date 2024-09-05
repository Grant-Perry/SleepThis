import SwiftUI

enum PositionColor {
   case qb, rb, wr, te, k, other

   var color: Color {
	  switch self {
		 case .qb: return .gpRedPink
		 case .rb: return .gpBlue
		 case .wr: return .gpPink
		 case .te: return .gpPurple
		 case .k: return .gpYellow
		 case .other: return .gpGreen
	  }
   }

   static func fromPosition(_ position: String?) -> PositionColor {
	  switch position?.uppercased() {
		 case "QB": return .qb
		 case "RB": return .rb
		 case "WR": return .wr
		 case "TE": return .te
		 case "K": return .k
		 default: return .other
	  }
   }
}
