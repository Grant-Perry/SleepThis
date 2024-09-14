import SwiftUI

struct AppConstants {
   static let cacheDays = 5.0
   static let verSize = 9.0
   static let verColor = Color.gpBlue

   static let sleeperID = "1117588009542615040"

   static let BigBoysLeagueID = "1136822872179224576"
   static let BigBoysDraftID = "1136822873030782976"

   //   static let TwoBrothersLeagueID = "1051207774316683264"
   //   static let TwoBrothersDraftID = "1116901677971398656"
   
   static let TwoBrothersLeagueID = "1044844006657982464"
   static let TwoBrothersDraftID = "1044844007601504256"

   static let leagueID = TwoBrothersLeagueID
   static let draftID = TwoBrothersDraftID

   static func getVersion() -> String {
	  return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
   }

}
