import SwiftUI

struct AppConstants {
   static let cacheDays = 5.0
   static let verSize = 10.0
   static let verColor = Color.teal
   static let leagueID = "1051207774316683264"
   static let TwoBrothersID = "1044844006657982464"
   static let DraftID = "1044844007601504256"


   static func getVersion() -> String {
	  return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
   }

}
