import SwiftUI
/// popup for Fantasy status when user clicks on a manager record from LView and DView
struct FantasyStatsAlert: View {
   let managerName: String
   let record: TeamRecord
   let selectedYear: Int

   private let numberFormatter: NumberFormatter = {
	  let formatter = NumberFormatter()
	  formatter.numberStyle = .decimal
	  formatter.minimumFractionDigits = 2
	  formatter.maximumFractionDigits = 2
	  return formatter
   }()

   var body: some View {
	  VStack {
		 Text(managerName)
			.font(.system(size: 20, weight: .bold))
			.foregroundColor(.gpYellow)
		 + Text("\n\n")
		 + Text("\(record.wins)-\(record.losses) • Ranked: \(getRankSuffix(record.rank))")
			.foregroundColor(.gpWhite)
		 + Text("Points For: ").foregroundColor(.gpWhite)
		 + Text(numberFormatter.string(from: NSNumber(value: record.totalPF)) ?? "0.00").foregroundColor(.gpGreen)
		 + Text("Points Against: ").foregroundColor(.gpWhite)
		 + Text(numberFormatter.string(from: NSNumber(value: record.totalPA)) ?? "0.00").foregroundColor(.gpGreen)
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
