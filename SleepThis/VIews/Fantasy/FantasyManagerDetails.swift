import SwiftUI

struct FantasyManagerDetails: View {
   let managerName: String
   let managerRecord: String
   let score: Double
   let isWinning: Bool
   let avatarURL: URL?
   var fantasyViewModel: FantasyMatchupViewModel? = nil
   var rosterID: Int? = nil
   let selectedYear: Int
   
   @State private var showStatsPopup = false
   
   var body: some View {
	  VStack(spacing: 4) {
		 // Avatar section
		 ZStack {
			if let url = avatarURL {
			   AsyncImage(url: url) { image in
				  image
					 .resizable()
					 .aspectRatio(contentMode: .fill)
					 .frame(width: 40, height: 40)
					 .clipShape(Circle())
			   } placeholder: {
				  Image(systemName: "person.crop.circle.fill")
					 .resizable()
					 .frame(width: 40, height: 40)
					 .foregroundColor(.gray)
			   }
			} else {
			   Image(systemName: "person.crop.circle.fill")
				  .resizable()
				  .frame(width: 40, height: 40)
				  .foregroundColor(.gray)
			}
			
			if isWinning {
			   Circle()
				  .strokeBorder(Color.green, lineWidth: 2)
				  .frame(width: 44, height: 44)
			}
		 }
		 
		 // Manager name
		 Text(managerName)
			.font(.system(size: 16, weight: .semibold))
			.foregroundColor(.gpYellow)
			.lineLimit(1)
			.minimumScaleFactor(0.8)
		 
		 // Record section - now using FantasyRecordView
		 if let viewModel = fantasyViewModel,
			let rosterID = rosterID {
			FantasyRecordView(
			   managerName: managerName,
			   managerID: rosterID.description,
			   fantasyViewModel: viewModel
			)
		 }
		 
		 // Score
		 Text(String(format: "%.2f", score))
			.font(.title3)
			.fontWeight(.bold)
			.foregroundColor(isWinning ? .gpGreen : .gpRedLight)
	  }
	  .frame(maxWidth: .infinity)
	  .sheet(isPresented: $showStatsPopup) {
		 if let viewModel = fantasyViewModel,
			let league = viewModel.currentManagerLeagues.first(where: { $0.id == viewModel.leagueID }),
			league.type == .sleeper,
			let record = viewModel.sleeperTeamRecords[rosterID ?? 0] {
			FantasyStatDetailView(
			   managerName: managerName,
			   record: record,
			   selectedYear: selectedYear,
			   showStatsPopup: $showStatsPopup
			)
			.presentationDetents([.height(360)])
			.presentationDragIndicator(.visible)
		 }
	  }
   }
   
   private func getRankSuffix(_ rank: Int) -> String {
	  let suffix: String
	  switch rank % 10 {
		 case 1 where rank % 100 != 11:
			suffix = "st"
		 case 2 where rank % 100 != 12:
			suffix = "nd"
		 case 3 where rank % 100 != 13:
			suffix = "rd"
		 default:
			suffix = "th"
	  }
	  return "\(rank)\(suffix)"
   }
}
