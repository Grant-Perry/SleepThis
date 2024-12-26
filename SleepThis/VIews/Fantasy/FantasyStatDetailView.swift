import SwiftUI

// Create a reusable component for manager W-L-T and PF/PA records
struct FantasyStatDetailView: View {
    let managerName: String
    let record: TeamRecord
    let selectedYear: Int
    @Binding var showStatsPopup: Bool
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                // Title with year
			   Text("\(selectedYear.formatted(.number.grouping(.never))) Season Stats")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                
                // Manager name
                Text(managerName)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.gpYellow)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 4)
                
                // Record and rank
                Text("\(record.wins)-\(record.losses) • Rank: \(getRankSuffix(record.rank))")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.gpWhite)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)
                
                // Points For
                Text("Points For: \(numberFormatter.string(from: NSNumber(value: record.totalPF)) ?? "0.00")")
                    .font(.system(size: 18))
                    .foregroundColor(.gpWhite)
                    .frame(maxWidth: .infinity)
                
                // Points Against
                Text("Points Against: \(numberFormatter.string(from: NSNumber(value: record.totalPA)) ?? "0.00")")
                    .font(.system(size: 18))
                    .foregroundColor(.gpWhite)
                    .frame(maxWidth: .infinity)
                
                // Close button
                Button(action: { showStatsPopup = false }) {
                    Text("Close")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gpBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .padding(.top, 16)
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal, 24)
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

// End of file. No additional code.
