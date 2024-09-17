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

				  Spacer()

				  // Player's Team Logo on the extreme right
				  if let teamLogoURL = URL(string: player.team?.logo ?? "") {
					 AsyncImage(url: teamLogoURL) { phase in
						switch phase {
						   case .empty:
							  Image(systemName: "photo")
								 .resizable()
								 .frame(width: 50, height: 50)
								 .opacity(0.25)
						   case .success(let image):
							  image
								 .resizable()
								 .frame(width: 50, height: 50) // Adjust size if needed
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
