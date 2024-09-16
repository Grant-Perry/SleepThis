import SwiftUI

struct RosterDetailListView: View {
   let players: [String]
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
			   let isUndrafted = backgroundColor == .gpUndrafted

			   // Fetch round and pickNo from draft details
			   let draftDetails = draftViewModel.getDraftDetails(for: playerID)
			   let round = draftDetails?.round != nil ? String(draftDetails!.round) : ""
			   let pickNo = draftDetails?.pick_no != nil ? String(draftDetails!.pick_no) : ""

			   // Fetch the managerID from the draftDetails, assuming draftDetails contains a managerID
			   let managerID = draftDetails?.picked_by ?? ""  // Modify this as per your data structure

			   // Get the manager's name and avatar using managerID instead of playerID
			   let managerName = draftViewModel.managerName(for: managerID)
			   let managerAvatarURL = draftViewModel.managerAvatar(for: managerID)

			   NavigationLink(destination: PlayerCardView(
				  playerModel: player,
				  thisBackgroundColor: backgroundColor,
				  round: round,
				  pick: pickNo,
				  managerName: managerName,
				  managerAvatarURL: managerAvatarURL
			   )) {
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
						   .foregroundColor(.gpDark2)

						HStack(spacing: 5) {
						   Text(player.position ?? "Unknown Position")
							  .font(.subheadline)
							  .bold()
							  .foregroundColor(PositionColor.fromPosition(player.position).color)

						   Text(fullTeamName(from: player.team))
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
					 if showDraftDetails {
						Text("\(round).\(pickNo)")
						   .font(.footnote)
						   .foregroundColor(.gpDark1)
						   .padding(.top, 5)
						   .padding(.horizontal)
					 }

					 // Icon for undrafted players
					 if backgroundColor == .gpUndrafted {
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
}
