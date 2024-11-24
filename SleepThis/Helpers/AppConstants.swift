import SwiftUI

struct AppConstants {
   static let maxCacheDays = 5.0
   static let verSize = 11.0
   static let verColor = Color.gpGreen

   static let GpESPNID = "%7B8A3B2780-FA70-4A52-9AFD-3BEE4D5A7468%7D"
   static let ESPNLeagueID = ["1241361400", "1365003638"]
//   static let ESPNLeagueID2 = "1365003638"
   static let ESPNLeagueYear = "2024"

   static let GpManagerID = "1117588009542615040"
   static let sleeperID = "1117588009542615040"
   static let GpSleeperID = "1117588009542615040"
   static let rossManagerID = "1044843366334828544"
   static let managerID = rossManagerID

   static let BigBoysLeagueID = "1136822872179224576"
   static let BigBoysDraftID = "1136822873030782976"

   static let TwoBrothersLeagueID = "1044844006657982464"
   static let TwoBrothersDraftID = "1044844007601504256"

   static let leagueID = TwoBrothersLeagueID
   static let SleeperLeagueID = TwoBrothersLeagueID
   static let draftID = TwoBrothersDraftID
   static let teamColor = Color(hex: "008C96")
   static let SWID = "{8A3B2780-FA70-4A52-9AFD-3BEE4D5A7468}"
   static let ESPN_S2 = "AEAQAAVXgHBaJ%2Fq1pPpnsckBKlBKXxsRJyttQjQhae67N%2Bz5kVdRdn001uU8V30qYT3z9n7R%2FsLNqWd%2BskxNWwMKr7kpL1%2Fs2J6BCvH8su%2F8gsDOcv44fRm6zbxMq6kQHoFdwGjSf7bnoMp8j5gDC29iDExGMF%2B5ObIreHcchFk8AQGZVNi2cSTCdxevEuioMNPDTbehk%2B4kPI1n5KxqtXnm9Z5gz5UpJv42IJNmT0nwfqMq9Vjz0MYqvj%2BbN7%2B5%2Bky9PwK8%2FUgAeWXObJ9ezOlCZGMmEO4Wyrq2dDl8DeGJKg%3D%3D"

   static let ESPN_AUTH = "{\"swid\":\"\(SWID)\"}"

   static func getVersion() -> String {
	  return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
   }
}

/*
 to test api in browser:

 document.cookie = "SWID={8A3B2780-FA70-4A52-9AFD-3BEE4D5A7468}; path=/; domain=.espn.com";
 document.cookie = "ESPN_S2=AEAQAAVXgHBaJ%2Fq1pPpnsckBKlBKXxsRJyttQjQhae67N%2Bz5kVdRdn001uU8V30qYT3z9n7R%2FsLNqWd%2BskxNWwMKr7kpL1%2Fs2J6BCvH8su%2F8gsDOcv44fRm6zbxMq6kQHoFdwGjSf7bnoMp8j5gDC29iDExGMF%2B5ObIreHcchFk8AQGZVNi2cSTCdxevEuioMNPDTbehk%2B4kPI1n5KxqtXnm9Z5gz5UpJv42IJNmT0nwfqMq9Vjz0MYqvj%2BbN7%2B5%2Bky9PwK8%2FUgAeWXObJ9ezOlCZGMmEO4Wyrq2dDl8DeGJKg%3D%3D; path=/; domain=.espn.com";

 */
