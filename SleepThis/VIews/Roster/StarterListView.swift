import SwiftUI

struct StarterListView: View {
   let starters: [String]
   @ObservedObject var playerViewModel: PlayerViewModel  // Add this property
   var playerSize = 65.0

   var body: some View {
	  VStack(alignment: .leading, spacing: 10) {
		 // Title for the Starters section
//		 Text("StartersP")
//			.font(.title)
//			.foregroundColor(.white)
//			.bold()
//			.padding(.bottom, 1)  // Padding below the title for spacing

		 // List of starters
		 ForEach(starters.prefix(9), id: \.self) { starterID in  // Prefix to limit to first 9
			HStack {
			   if let url = URL(string: "https://sleepercdn.com/content/nfl/players/\(starterID).jpg") {
				  AsyncImage(url: url) { image in
					 image.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: playerSize, height: playerSize)
						.clipShape(Circle())
				  } placeholder: {
					 Image(systemName: "person.crop.circle")
						.resizable()
						.frame(width: playerSize, height: playerSize)
				  }
			   }

			   VStack(alignment: .leading) {
				  if let player = playerViewModel.players.first(where: { $0.id == starterID }) {
					 Text(player.fullName ?? "Unknown Player")
						.font(.headline)
					 HStack {
						Text(player.position ?? "Unknown Position")
						   .bold()
						   .foregroundColor(PositionColor.fromPosition(player.position).color)
						Text(fullTeamName(from: player.team))
						   .font(.footnote)
						   .foregroundColor(.secondary)
						   .bold()
					 }
				  } else {
					 Text("No Player Rostered")
						.foregroundColor(.gpDeltaPurple)
					 Text("")
				  }
			   }
			}

//			.frame(maxWidth: .infinity)
//			.background(.blue.gradient)
			.padding(.vertical, 1)
		 }
	  }
   }
}
