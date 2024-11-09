import SwiftUI

struct LivePlayerImageView: View {
   let playerID: Int?
   let picSize: CGFloat

   // Default initializer with Int? for playerID
   init(playerID: Int?, picSize: CGFloat) {
	  self.playerID = playerID
	  self.picSize = picSize
   }

   // Additional initializer accepting a String playerID
   init(playerID: String, picSize: CGFloat) {
	  self.playerID = Int(playerID)  // Convert String to Int?
	  self.picSize = picSize
   }

   var body: some View {
	  let imageUrl = URL(string: "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/\(playerID ?? 0).png")

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
