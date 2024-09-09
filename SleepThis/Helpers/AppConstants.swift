import SwiftUI

struct AppConstants {
   static let cacheDays = 5.0
   static let verSize = 10.0
   static let verColor = Color.teal
   
   static let BigBoysLeagueID = "1136822872179224576"
   static let BigBoysDraftID = "1136822873030782976"
   
   static let TwoBrothersLeagueID = "1044844006657982464"
   static let TwoBrothersDraftID = "1044844007601504256"

   static let leagueID = BigBoysLeagueID
   static let draftID = BigBoysDraftID

   static func getVersion() -> String {
	  return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
   }

}
