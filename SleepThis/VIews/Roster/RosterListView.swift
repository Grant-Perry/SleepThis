import SwiftUI

struct RosterListView: View {
   let players: [String]
   @ObservedObject var playerViewModel: PlayerViewModel
   @ObservedObject var draftViewModel: DraftViewModel
   @ObservedObject var rosterViewModel: RosterViewModel
   var playerSize = 50.0
   var showDraftDetails = false

   var body: some View {
	  VStack(alignment: .leading) {
		 ForEach(players, id: \.self) { playerID in
			if let player = playerViewModel.players.first(where: { $0.id == playerID }) {
			   // Get drafting manager's color from the RosterViewModel
			   let backgroundColor = rosterViewModel.getBackgroundColor(for: playerID, draftViewModel: draftViewModel)
			   let isUndrafted = backgroundColor == .gpBlueDarkL

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
				  }

				  // Icon for undrafted players
				  if isUndrafted {
					 Image(systemName: "pencil.slash")
						.resizable()
						.frame(width: 15, height: 15)
						.foregroundColor(.red)
						.padding(.trailing, 10)
				  }
			   }
			   .padding(.vertical, 8)
			   .padding(.horizontal)
			   .background(
				  RoundedRectangle(cornerRadius: 15)
					 .fill(LinearGradient(
						gradient: Gradient(colors: [
						   backgroundColor,
						   backgroundColor.blended(withFraction: 0.55, of: .white)
						]),
						startPoint: .top,
						endPoint: .bottom
					 ))
					 .shadow(radius: 4)
			   )
			   .padding(.bottom, 4)
			}
		 }
	  }
   }
}
