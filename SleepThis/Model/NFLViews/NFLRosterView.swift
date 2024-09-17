import SwiftUI

struct NFLRosterView: View {
   @StateObject var nflRosterViewModel = NFLRosterViewModel()

   var body: some View {
	  NavigationStack {
		 List(nflRosterViewModel.players) { player in
			NavigationLink(destination: NFLPlayerDetailView(player: player)) {
			   HStack {
				  // Player Thumbnail
				  AsyncImage(url: player.imageUrl) { phase in
					 switch phase {
						case .empty:
						   Image(systemName: "person.crop.circle.fill")
							  .resizable()
							  .frame(width: 50, height: 50)
						case .success(let image):
						   image
							  .resizable()
							  .aspectRatio(contentMode: .fit)
							  .frame(width: 50, height: 50)
							  .clipShape(Circle())
						case .failure:
						   Image(systemName: "person.crop.circle.fill")
							  .resizable()
							  .frame(width: 50, height: 50)
						@unknown default:
						   EmptyView()
					 }
				  }

				  VStack(alignment: .leading) {
					 Text(player.fullName)
						.font(.headline)

					 // Displaying position and team abbreviation
					 HStack {
						Text(player.positionAbbreviation ?? "Unknown Position")
						   .font(.subheadline)
						   .bold()
						   .foregroundColor(PositionColor.fromPosition(player.positionAbbreviation).color)

						if let teamAbbreviation = player.team?.abbreviation {
						   Text(teamAbbreviation)
							  .font(.subheadline)
							  .foregroundColor(.secondary)
						}
					 }
				  }
			   }
			}
		 }
		 .navigationTitle("NFL Roster")
		 .onAppear {
			nflRosterViewModel.fetchPlayersForAllTeams()
			print("[NFLRosterView:onAppear] Loaded \(nflRosterViewModel.players.count) players.")
		 }
	  }
   }
}
