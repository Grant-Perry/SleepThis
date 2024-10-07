import SwiftUI

struct AppConstants {
   static let maxCacheDays = 5.0
   static let verSize = 11.0
   static let verColor = Color.gpGreen

   static let ESPNLeagueID = "1241361400"
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
   static let SWID = "{8A3B2780-FA70-4A52-9AFD-3BEE4D5A7468}"
   static let ESPN_S2 = "AEAs7iuz4j6mHD9HJyTiXfTC35XqZ3n2mz3wGD9VbaQb9091HVxiUcyVYgGMEz0DHd77lYuB11RWWVy65M5lsDwQpEJadkY7wH%2F9u%2FJEtQWQeYeNE89q9DOk849MKB0zWzxdSQ1mWIKo%2BFC1kqVu9p%2F9itqThIXzizifnZrnCt0V01JWJnAq%2FYesiUbTS1EVbBB%2FIkvB8IE8jOobZXUGuhsi4r1OsexJwARKl%2B03i2T2TPdn5jTE7ZVNbbQIvX%2FTepfuTSKtVPr1iOFBmqfsF8nHfzORFdHsWYaKNJmuH2fiSQ%3D%3D"

   static func getVersion() -> String {
	  return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
   }
   /*

	document.cookie = "SWID={8A3B2780-FA70-4A52-9AFD-3BEE4D5A7468}; ESPN_S2=AEAs7iuz4j6mHD9HJyTiXfTC35XqZ3n2mz3wGD9VbaQb9091HVxiUcyVYgGMEz0DHd77lYuB11RWWVy65M5lsDwQpEJadkY7wH%2F9u%2FJEtQWQeYeNE89q9DOk849MKB0zWzxdSQ1mWIKo%2BFC1kqVu9p%2F9itqThIXzizifnZrnCt0V01JWJnAq%2FYesiUbTS1EVbBB%2FIkvB8IE8jOobZXUGuhsi4r1OsexJwARKl%2B03i2T2TPdn5jTE7ZVNbbQIvX%2FTepfuTSKtVPr1iOFBmqfsF8nHfzORFdHsWYaKNJmuH2fiSQ%3D%3D";
	*/
}
