/// The popup to show the win-loss Points for/against record for a manager in a fantasy league.
import SwiftUI

struct FantasyRecordView: View {
   let managerName: String
   let managerID: String
   let fantasyViewModel: FantasyMatchupViewModel
   @State private var showStatsPopup = false

   var body: some View {
	  // If it's an ESPN league, show only win-loss record
	  if let league = fantasyViewModel.currentManagerLeagues.first(where: { $0.id == fantasyViewModel.leagueID }) {
		 if league.type == .espn {
			// Just show W-L for ESPN leagues
			if let record = fantasyViewModel.managerRecords[managerID] {
			   Text("\(record.wins)-\(record.losses)")
				  .font(.system(size: 12, weight: .medium))
				  .foregroundColor(.gray)
				  .lineLimit(1)
				  .minimumScaleFactor(0.8)
			}
		 } else {
			// Show full stats for Sleeper leagues
			if let rosterID = Int(managerID),
			   let record = fantasyViewModel.sleeperTeamRecords[rosterID] {
			   VStack(spacing: 2) {
				  Text("\(record.wins)-\(record.losses) • Rank: \(getRankSuffix(record.rank))")
					 .font(.system(size: 12, weight: .medium))
					 .foregroundColor(.gray)
					 .lineLimit(1)
					 .minimumScaleFactor(0.8)

				  Button(action: {
					 showStatsPopup = true
				  }) {
					 Text("PF: \(getRankSuffix(record.pfRank)) • PA: \(getRankSuffix(record.paRank))")
						.font(.system(size: 12, weight: .medium))
						.foregroundColor(.gray)
						.lineLimit(1)
						.minimumScaleFactor(0.8)
				  }
			   }
			   .fullScreenCover(isPresented: $showStatsPopup) {
				  FantasyStatDetailView(
					 managerName: managerName,
					 record: record,
					 selectedYear: fantasyViewModel.selectedYear,
					 showStatsPopup: $showStatsPopup
				  )
			   }
			}
		 }
	  }
   }

   private func getRankSuffix(_ rank: Int) -> String {
	  let suffix: String
	  switch rank % 10 {
		 case 1 where rank % 100 != 11: suffix = "st"
		 case 2 where rank % 100 != 12: suffix = "nd"
		 case 3 where rank % 100 != 13: suffix = "rd"
		 default: suffix = "th"
	  }
	  return "\(rank)\(suffix)"
   }
}
