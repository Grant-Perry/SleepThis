import SwiftUI

struct StarterListView: View {
   let starters: [String]
   @StateObject var playerViewModel: PlayerViewModel
   var playerSize = 50.0

   var body: some View {
	  VStack(alignment: .leading) {
		 ForEach(starters, id: \.self) { playerID in
			if let player = playerViewModel.players.first(where: { $0.id == playerID }) {
			   HStack(alignment: .center, spacing: 10) {
				  // Player Thumbnail
				  if let url = URL(string: "https://sleepercdn.com/content/nfl/players/\(playerID).jpg") {
					 AsyncImage(url: url) { image in
						image
						   .resizable()
						   .aspectRatio(contentMode: .fill)
						   .frame(width: playerSize, height: playerSize)
						   .clipShape(Circle())
					 } placeholder: {
						Image(systemName: "person.crop.circle")
						   .resizable()
						   .frame(width: playerSize, height: playerSize)
					 }
				  }

				  // Player Details
				  VStack(alignment: .leading, spacing: 2) {
					 Text(player.fullName ?? "Unknown Player")
						.font(.headline)
					 HStack(spacing: 5) {
						Text(player.position ?? "Unknown Position")
						   .font(.subheadline)
						   .bold()
						   .foregroundColor(PositionColor.fromPosition(player.position).color)
						Text(fullTeamName(from: player.team))
						   .font(.footnote)
						   .bold()
						   .foregroundColor(.secondary)
					 }
				  }

				  Spacer()
			   }
			   .padding(.vertical, 8)
			}
		 }
	  }
   }
}
