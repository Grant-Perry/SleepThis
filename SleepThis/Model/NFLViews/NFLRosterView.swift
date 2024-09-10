import SwiftUI


struct NFLRosterView: View {
   @StateObject var nflRosterViewModel = NFLRosterViewModel()

   var body: some View {
	  NavigationStack {
		 List(nflRosterViewModel.players) { player in
			NavigationLink(destination: NFLPlayerDetailView(player: player, nflRosterViewModel: nflRosterViewModel)) {
			   HStack {
				  // Player Thumbnail
				  AsyncImage(url: nflRosterViewModel.getPlayerImageURL(for: player)) { image in
					 image.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 50, height: 50)
						.clipShape(Circle())
				  } placeholder: {
					 Image(systemName: "person.crop.circle.fill")
						.resizable()
						.frame(width: 50, height: 50)
				  }
				  .onAppear() {
					 if let url = nflRosterViewModel.getPlayerImageURL(for: player) {
						print("Player image URL: \(url)")
					 }
				  }

				  VStack(alignment: .leading) {
					 Text(player.fullName)
						.font(.headline)
					 Text(player.college?.name ?? "Unknown College")
						.font(.subheadline)
						.foregroundColor(.secondary)
				  }
			   }
			}
		 }
		 .navigationTitle("NFL Roster")
		 .onAppear {
			print("[NFLRosterView:onAppear] Loaded \(nflRosterViewModel.players.count) players.")
		 }
	  }
   }
}
