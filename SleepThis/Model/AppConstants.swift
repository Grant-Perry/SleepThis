import SwiftUI

struct AppConstants {
   static let cacheDays = 5.0
   static let leagueID = "1051207774316683264"

   static func getVersion() -> String {
	  return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
   }

}
