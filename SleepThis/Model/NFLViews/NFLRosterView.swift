import SwiftUI

struct NFLRosterView: View {
   @StateObject var nflRosterViewModel = NFLRosterViewModel()

   var body: some View {
	  NavigationStack {
		 List(nflRosterViewModel.players) { player in
			// Fetch the team and coach details for each player
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
					 Text(player.position?.name ?? "Unknown Position")
						.font(.subheadline)
						.bold()
						.foregroundColor(PositionColor.fromPosition(player.position?.displayName).color)
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
