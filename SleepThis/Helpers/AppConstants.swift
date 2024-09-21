import SwiftUI

struct AppConstants {
   static let maxCacheDays = 5.0
   static let verSize = 11.0
   static let verColor = Color.gpGreen
   
   static let GpManagerID = "1117588009542615040"
   static let sleeperID = "1117588009542615040"
   
   static let rossManagerID = "1044843366334828544"
   static let managerID = rossManagerID
   
   
   static let BigBoysLeagueID = "1136822872179224576"
   static let BigBoysDraftID = "1136822873030782976"
   
   //   static let TwoBrothersLeagueID = "1051207774316683264"
   //   static let TwoBrothersDraftID = "1116901677971398656"
   
   static let TwoBrothersLeagueID = "1044844006657982464"
   static let TwoBrothersDraftID = "1044844007601504256"
   
   static let leagueID = TwoBrothersLeagueID
   static let draftID = TwoBrothersDraftID
   static let teamColor = Color(hex: "008C96")

   static func getVersion() -> String {
	  return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
   }
   
}
