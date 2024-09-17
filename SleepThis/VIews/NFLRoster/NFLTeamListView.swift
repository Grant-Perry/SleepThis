import SwiftUI

struct NFLTeamListView: View {
   @StateObject var nflRosterViewModel = NFLRosterViewModel()

   var body: some View {
	  NavigationStack {
		 List {
			ForEach(nflRosterViewModel.teams.sorted(by: { $0.displayName < $1.displayName }), id: \.id) { team in
			   NavigationLink(destination: NFLRosterView(team: team, nflRosterViewModel: nflRosterViewModel)) {
				  HStack {
					 // Team Logo
					 if let teamLogoURL = URL(string: team.logo ?? "") {
						AsyncImage(url: teamLogoURL) { phase in
						   switch phase {
							  case .empty:
								 Image(systemName: "photo")
									.resizable()
									.frame(width: 50, height: 50)
									.opacity(0.5)
							  case .success(let image):
								 image
									.resizable()
									.frame(width: 50, height: 50)
									.clipShape(Circle())
							  case .failure:
								 Image(systemName: "photo")
									.resizable()
									.frame(width: 50, height: 50)
									.opacity(0.5)
							  @unknown default:
								 EmptyView()
						   }
						}
					 } else {
						Image(systemName: "questionmark.circle.fill")
						   .resizable()
						   .frame(width: 50, height: 50)
						   .foregroundColor(.gray)
					 }

					 Text(team.displayName)
						.font(.headline)
				  }
			   }
			}
		 }
		 .navigationTitle("Select Team")
		 .onAppear {
			nflRosterViewModel.fetchPlayersForAllTeams {
			   // Handle any completion
			}
		 }
	  }
   }
}
