import SwiftUI

struct LivePlayerImageView: View {
   let playerID: Int?
   let picSize: CGFloat

   var body: some View {
	  let playerID = playerID ?? 0
	  let imageUrl = URL(string: "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/\(playerID).png")

	  AsyncImage(url: imageUrl) { phase in
		 switch phase {
			case .empty:
			   Image(systemName: "american.football")
				  .resizable()
				  .frame(width: 25, height: 25)
			case .success(let image):
			   image
				  .resizable()
				  .scaledToFill()
				  .frame(width: picSize, height: picSize)
//				  .clipShape(Circle())
			case .failure:
			   Image(systemName: "american.football")
				  .resizable()
				  .frame(width: 25, height: 25)
			@unknown default:
			   EmptyView()
		 }
	  }
   }
}
