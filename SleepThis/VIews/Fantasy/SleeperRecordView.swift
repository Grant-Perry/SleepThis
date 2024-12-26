import SwiftUI

struct SleeperRecordView: View {
    let record: TeamRecord
    @State private var showDetailsPopup = false
    
    var body: some View {
        Button(action: {
            showDetailsPopup = true
        }) {
            Text("\(record.wins)-\(record.losses) • Rank: \(getRankSuffix(record.rank)) • PF: \(getRankSuffix(record.pfRank)) • PA: \(getRankSuffix(record.paRank))")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .alert("Season Stats", isPresented: $showDetailsPopup) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Total Points For: \(String(format: "%.2f", record.totalPF))\nTotal Points Against: \(String(format: "%.2f", record.totalPA))")
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
