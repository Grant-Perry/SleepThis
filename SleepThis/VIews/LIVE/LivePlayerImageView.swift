import SwiftUI

struct LivePlayerImageView: View {
   let playerID: Int?

   var body: some View {
	  let playerID = playerID ?? 0
	  let imageUrl = URL(string: "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/\(playerID).png")

	  AsyncImage(url: imageUrl) { phase in
		 switch phase {
			case .empty:
			   Image(systemName: "person.crop.circle.fill")
				  .resizable()
				  .frame(width: 180, height: 180)
			case .success(let image):
			   image
				  .resizable()
				  .scaledToFill()
				  .frame(width: 180, height: 180)
//				  .clipShape(Circle())
			case .failure:
			   Image(systemName: "person.crop.circle.fill")
				  .resizable()
				  .frame(width: 180, height: 180)
			@unknown default:
			   EmptyView()
		 }
	  }
   }
}
