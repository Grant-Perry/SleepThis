import SwiftUI

//  view for matchups list
struct FantasyMatchupsListView: View {
    @ObservedObject var fantasyViewModel: FantasyMatchupViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(fantasyViewModel.matchups, id: \.self) { matchup in
                    NavigationLink(value: matchup) {
                        FantasyMatchupCardView(
                            matchup: matchup,
                            fantasyViewModel: fantasyViewModel
                        )
                        .overlay(
                            HStack {
                                avatarOverlay(for: matchup.awayTeamID.description)
                                Spacer()
                                avatarOverlay(for: matchup.homeTeamID.description)
                            }
                        )
                    }
                    .contextMenu {
                        Button("View \(matchup.managerNames[0])'s Leagues") {
                            fantasyViewModel.updateSelectedManager(matchup.homeTeamID.description)
                        }
                        Button("View \(matchup.managerNames[1])'s Leagues") {
                            fantasyViewModel.updateSelectedManager(matchup.awayTeamID.description)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationDestination(for: AnyFantasyMatchup.self) { matchup in
            FantasyMatchupDetailView(
                matchup: matchup,
                fantasyViewModel: fantasyViewModel,
                leagueName: fantasyViewModel.leagueName
            )
        }
    }
    
    private func avatarOverlay(for managerID: String) -> some View {
        Circle()
            .fill(Color.clear)
            .frame(width: 40, height: 40)
            .onTapGesture {
                fantasyViewModel.updateSelectedManager(managerID)
            }
    }
}

// End of file. No additional code.
