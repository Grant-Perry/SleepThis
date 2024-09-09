import SwiftUI

struct BenchView: View {
   let benchPlayers: [String]
   @ObservedObject var playerViewModel: PlayerViewModel
   var playerSize = 50.0

   var body: some View {
	  VStack(alignment: .leading) {
		 Text("Bench")
			.font(.title)
			.bold()
			.foregroundColor(.white)
			.padding(.bottom, 10)

		 ForEach(benchPlayers, id: \.self) { playerID in
			HStack {
			   if let url = URL(string: "https://sleepercdn.com/content/nfl/players/\(playerID).jpg") {
				  AsyncImage(url: url) { image in
					 image.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: playerSize, height: playerSize)
						.clipShape(Circle())
				  } placeholder: {
					 Image(systemName: "person.crop.circle")
						.resizable()
						.frame(width: playerSize, height: playerSize)
				  }
			   }

			   VStack(alignment: .leading) {
				  if let player = playerViewModel.players.first(where: { $0.id == playerID }) {
					 Text(player.fullName ?? "Unknown Player")
						.font(.headline)
					 HStack {
						Text(player.position ?? "Unknown Position")
						   .font(.subheadline)
						   .bold()
						   .foregroundColor(PositionColor.fromPosition(player.position).color)
						Text(fullTeamName(from: player.team))
						   .font(.footnote)
						   .bold()
						   .foregroundColor(.secondary)
						   .padding(.leading, 5)
					 }
				  } else {
					 Text("No Player Rostered")
						.foregroundColor(.gpDeltaPurple)
					 Text("")
				  }
			   }
			}
			.padding(.vertical, 8)
		 }
	  }
   }
}
