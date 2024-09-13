import SwiftUI

struct RosterListView: View {
   let players: [String]
   @ObservedObject var playerViewModel: PlayerViewModel
   @ObservedObject var draftViewModel: DraftViewModel
   var playerSize = 50.0
   var showDraftDetails = false
   var backgroundColor: Color  // New background color parameter

   var body: some View {
	  VStack(alignment: .leading) {
		 ForEach(players, id: \.self) { playerID in
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

				  // Draft Details (optional)
				  if showDraftDetails, let draftDetails = draftViewModel.getDraftDetails(for: playerID) {
					 Text("\(draftDetails.round).\(draftDetails.pick_no)")
						.font(.footnote)
						.foregroundColor(.gray)
						.padding(.top, 5)
						.padding(.horizontal)
				  }
			   }
			   .padding(.vertical, 8)
			   .padding(.horizontal)  // Added horizontal padding for row spacing
			   .background(
				  RoundedRectangle(cornerRadius: 15)
					 .fill(LinearGradient(
						gradient: Gradient(colors: [
						   backgroundColor,
						   backgroundColor.blended(withFraction: 0.55, of: .white)  // Same background effect as manager section
						]),
						startPoint: .top,
						endPoint: .bottom
					 ))
					 .shadow(radius: 4)  // Added shadow for consistency
			   )
			   .padding(.bottom, 4)  // Spacing between rows
			}
		 }
	  }
   }
}
