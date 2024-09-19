import SwiftUI

struct DraftRowView: View {
   let draft: DraftModel
   let playerSize: CGFloat = 160

   var body: some View {
	  HStack {
		 // Player Image on the left using the `player_id` from `DraftModel`
		 if let url = URL(string: "https://sleepercdn.com/content/nfl/players/\(draft.player_id).jpg") {
			AsyncImage(url: url) { image in
			   image
				  .resizable()
				  .aspectRatio(contentMode: .fit)
				  .frame(width: playerSize, height: playerSize)
//				  .isOnIR(player.status, hXw: playerSize)
				  .padding(EdgeInsets(top: 0, leading: -15, bottom: 0, trailing: 0))

			} placeholder: {
			   Image(systemName: "person.crop.circle.fill")
				  .resizable()
				  .frame(width: playerSize, height: playerSize)
			}
		 }

		 // Player details in the middle
		 VStack(alignment: .leading) {
			Text("\(draft.metadata?.first_name ?? "") \(draft.metadata?.last_name ?? "")")
			   .font(.headline)
			   .padding(EdgeInsets(top: 12, leading: -15, bottom: 0, trailing: 0))

			// Apply the foreground color based on the position
			Text(draft.metadata?.position ?? "")
			   .font(.subheadline)
			   .fontWeight(.bold)
			   .foregroundColor(PositionColor.fromPosition(draft.metadata?.position).color) +
			Text("     #\(draft.metadata?.number ?? "-")")
			   .font(.subheadline)
			   .foregroundColor(.secondary)

			// Use the full NFL team name
			Text(fullTeamName(from: draft.metadata?.team))
			   .font(.subheadline)
			   .foregroundColor(.gpYellowD)
		 }
		 Spacer()

		 // Round information on the right
		 Text("\(draft.round).\(draft.pick_no)")
			.font(.footnote)
	  }
	  .padding(.vertical, 4)
//	  .background(PositionColor.fromPosition(draft.metadata?.position).color)
   }
}
