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
			   Image(systemName: "person.crop.circle.fill")
				  .resizable()
				  .frame(width: picSize, height: picSize)
			case .success(let image):
			   image
				  .resizable()
				  .scaledToFill()
				  .frame(width: picSize, height: picSize)
//				  .clipShape(Circle())
			case .failure:
			   Image(systemName: "person.crop.circle.fill")
				  .resizable()
				  .frame(width: picSize, height: picSize)
			@unknown default:
			   EmptyView()
		 }
	  }
   }
}
