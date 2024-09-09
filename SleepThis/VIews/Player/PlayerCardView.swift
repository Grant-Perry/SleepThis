import SwiftUI

struct PlayerCardView: View {
   let playerModel: PlayerModel

   var body: some View {
	  HStack {
		 // Player Thumbnail
		 if let url = URL(string: "https://sleepercdn.com/content/nfl/players/\(playerModel.id).jpg") {
			AsyncImage(url: url) { image in
			   image.resizable()
				  .frame(width: 50, height: 50)
				  .clipShape(Circle())
			} placeholder: {
			   Image(systemName: "person.crop.circle.fill")
				  .resizable()
				  .frame(width: 50, height: 50)
			}
		 }

		 // Player Details
		 VStack(alignment: .leading) {
			Text("\(playerModel.firstName ?? "") \(playerModel.lastName ?? "")")
			   .font(.headline)
			Text("\(playerModel.position ?? "") - \(playerModel.team ?? "") (\(playerModel.number ?? 0))")
			   .font(.subheadline)
			   .foregroundColor(.secondary)
		 }
		 Spacer()

		 // Metrics (if any) can be displayed here
	  }
	  .padding(.vertical, 8)
   }
}
