import SwiftUI

struct BenchListView: View {
   let benchPlayers: [String]
   @ObservedObject var playerViewModel: PlayerViewModel
   @ObservedObject var draftViewModel: DraftViewModel
   var playerSize = 50.0

   var body: some View {
	  VStack(alignment: .leading) {
		 ForEach(benchPlayers, id: \.self) { playerID in
			if let player = playerViewModel.players.first(where: { $0.id == playerID }) {
			   HStack(alignment: .center) {
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
				  VStack(alignment: .leading) {
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
				  }
				  Spacer()
				  // Draft Details
				  if let draftDetails = draftViewModel.getDraftDetails(for: playerID) {
					 Text("\(draftDetails.round).\(draftDetails.pick_no)")
						.font(.footnote)
						.foregroundColor(.gray)
						.padding(.top, 5)
						.padding(.horizontal)
				  }
			   }
			   .padding(.vertical, 8)
			}
			// If player is not found, do not display anything (omit "No Player Rostered")
		 }
	  }
   }
}
