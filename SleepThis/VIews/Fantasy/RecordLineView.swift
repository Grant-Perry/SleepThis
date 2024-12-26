// Add this new file: RecordLineView.swift
import SwiftUI

struct RecordStatsModel {
   let wins: Int
   let losses: Int
   let rank: Int
   let pfRank: Int
   let paRank: Int
   let totalPF: Double
   let totalPA: Double
}

struct RecordLineView: View {
   let stats: RecordStatsModel
   @State private var showDetailsPopup = false

   var body: some View {
	  Button(action: {
		 showDetailsPopup = true
	  }) {
		 Text("\(stats.wins)-\(stats.losses) • Rank: \(getRankSuffix(stats.rank)) • PF: \(getRankSuffix(stats.pfRank)) • PA: \(getRankSuffix(stats.paRank))")
			.font(.system(size: 12, weight: .medium))
			.foregroundColor(.gray)
			.lineLimit(1)
			.minimumScaleFactor(0.8)
	  }
	  .alert("Season Stats", isPresented: $showDetailsPopup) {
		 Button("OK", role: .cancel) {}
	  } message: {
		 Text("Total Points For: \(String(format: "%.2f", stats.totalPF))\nTotal Points Against: \(String(format: "%.2f", stats.totalPA))")
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
