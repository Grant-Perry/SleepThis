import SwiftUI

struct RosterDetailListView: View {
   let players: [String] // Ensure this is a plain array, not a Binding
   @StateObject var playerViewModel: PlayerViewModel
   @StateObject var draftViewModel: DraftViewModel
   @StateObject var rosterViewModel: RosterViewModel
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
//					 Text("\(player.id)")
//						.font(.caption)
						.foregroundColor(.gpDark2)


					 HStack(spacing: 5) {
						Text(player.position ?? "Unknown Position")
						   .font(.subheadline)
						   .bold()
						   .foregroundColor(PositionColor.fromPosition(player.position).color)

						Text(fullTeamName(from: player.team))
//						   .frame(maxWidth: .infinity)
						   .padding(.trailing)
						   .foregroundColor(.gpBlueDarkL)
						   .lineLimit(1)
						   .minimumScaleFactor(0.5)
						   .scaledToFit()
						   .font(.footnote)
						   .bold()

						Spacer()
					 }
				  }

				  Spacer()

				  // Draft Details (optional)
				  if showDraftDetails, let draftDetails = draftViewModel.getDraftDetails(for: playerID) {
					 Text("\(draftDetails.round).\(draftDetails.pick_no)")
						.font(.footnote)
						.foregroundColor(.gpDark1)
						.padding(.top, 5)
						.padding(.horizontal)
						.onAppear {
						   print("draft details: \(draftDetails)") //\nplayer: \(playerID)")
						}
				  }


				  // Icon for undrafted players
				  if backgroundColor == .gpGray {
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
