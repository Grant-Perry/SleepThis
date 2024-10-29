//import SwiftUI
//
//struct ESPNPlayerView: View {
//   let player: ESPNFantasy.ESPNFantasyModel.Player
//
//   var body: some View {
//	  HStack {
//		 // Display player image using AsyncImage
//		 let playerID = player.fullName
//		 let imageUrl = URL(string: "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/\(playerID).png")
//
//		 AsyncImage(url: imageUrl) { phase in
//			switch phase {
//			   case .empty:
//				  Image(systemName: "person.crop.circle.fill")
//					 .resizable()
//					 .frame(width: 40, height: 40)
//			   case .success(let image):
//				  image
//					 .resizable()
//					 .scaledToFill()
//					 .frame(width: 40, height: 40)
//			   case .failure:
//				  Image(systemName: "person.crop.circle.fill")
//					 .resizable()
//					 .frame(width: 40, height: 40)
//			   @unknown default:
//				  EmptyView()
//			}
//		 }
//
//		 VStack(alignment: .leading) {
//			Text(player.fullName)
//			Text("Points: \(player.stats.first?.appliedTotal ?? 0, specifier: "%.2f")")
//			   .font(.subheadline)
//		 }
//	  }
//   }
//}
