
import SwiftUI

struct RosterPlayerRowView: View {
   let player: PlayerModel

   var body: some View {
	  HStack {
		 // Player Image
		 if let url = URL(string: "https://sleepercdn.com/content/nfl/players/\(player.id).jpg") {
			AsyncImage(url: url) { image in
			   image
				  .resizable()
				  .aspectRatio(contentMode: .fill)
				  .frame(width: 50, height: 50)
				  .clipShape(Circle())
			} placeholder: {
			   Image(systemName: "person.crop.circle")
				  .resizable()
				  .frame(width: 50, height: 50)
			}
		 }

		 VStack(alignment: .leading) {
			Text("\(player.firstName ?? "Unknown") \(player.lastName ?? "Unknown")")
			   .font(.headline)
			Text(player.team ?? "Unknown Team")
			   .font(.subheadline)
			Text(player.position ?? "Unknown Position")
			   .font(.subheadline)
		 }
		 Spacer()
	  }
	  .padding(.vertical, 8)
   }
}
