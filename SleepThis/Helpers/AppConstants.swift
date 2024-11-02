import SwiftUI

struct AppConstants {
   static let maxCacheDays = 5.0
   static let verSize = 11.0
   static let verColor = Color.gpGreen

   static let ESPNLeagueID = "1241361400"
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

   /*

	document.cookie = "SWID={8A3B2780-FA70-4A52-9AFD-3BEE4D5A7468}; ESPN_S2=AEAs7iuz4j6mHD9HJyTiXfTC35XqZ3n2mz3wGD9VbaQb9091HVxiUcyVYgGMEz0DHd77lYuB11RWWVy65M5lsDwQpEJadkY7wH%2F9u%2FJEtQWQeYeNE89q9DOk849MKB0zWzxdSQ1mWIKo%2BFC1kqVu9p%2F9itqThIXzizifnZrnCt0V01JWJnAq%2FYesiUbTS1EVbBB%2FIkvB8IE8jOobZXUGuhsi4r1OsexJwARKl%2B03i2T2TPdn5jTE7ZVNbbQIvX%2FTepfuTSKtVPr1iOFBmqfsF8nHfzORFdHsWYaKNJmuH2fiSQ%3D%3D";


	curl -H "Cookie: SWID={8A3B2780-FA70-4A52-9AFD-3BEE4D5A7468}; ESPN_S2=AEAeVzZPwaU96GaPziNkt7%2BlIW7oWK7yyUkwTPLwpvxRnGimr0diZhG3u2HdNjGWn96SPd6asmBIuK0MLahC2cWz85aDKcm3Jjpkm4IVDRWbbh60ux62JUrRTKDUVVBPw%2BmehFbRJOK0tIROmoehaJtNpYUR%2BBnZvC9ac0mjMxvKLhoMqEKmx2hiWH%2FG%2BjFMKWiFZe%2FPpXiH5UOEwnfzXOvxJx3SX4vYoz2eFqNIP8ZnIZUHn0ll4vbdOs4fsotCGzw6ImbPNhJgyH3bre1b9obBYsv0smX9pDXAhsurHlgFaQ%3D%3D"

	https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/2024/segments/0/leagues/1241361400?view=mMatchupScore&view=mLiveScoring&view=mRoster



	*/
}

