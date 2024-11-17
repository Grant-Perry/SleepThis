import SwiftUI

struct FantasyTeamHeaderView: View {
   let managerName: String
   let score: Double
   let avatarURL: URL?
   let isWinning: Bool

   var body: some View {
	  VStack(spacing: 12) {
		 ZStack {
			// Avatar
			if let url = avatarURL {
			   AsyncImage(url: url) { image in
				  image
					 .resizable()
					 .aspectRatio(contentMode: .fill)
					 .frame(width: 60, height: 60)
					 .clipShape(Circle())
			   } placeholder: {
				  Image(systemName: "person.crop.circle.fill")
					 .resizable()
					 .frame(width: 60, height: 60)
					 .foregroundColor(.gray)
			   }
			} else {
			   Image(systemName: "person.crop.circle.fill")
				  .resizable()
				  .frame(width: 60, height: 60)
				  .foregroundColor(.gray)
			}

			if isWinning {
			   Circle()
				  .strokeBorder(Color.green, lineWidth: 3)
				  .frame(width: 66, height: 66)
			}
		 }

		 VStack(spacing: 4) {
			Text(managerName)
			   .font(.headline)
			   .fontWeight(.medium)
			   .lineLimit(1)
			   .minimumScaleFactor(0.8)

			Text(String(format: "%.1f", score))
			   .font(.title2)
			   .fontWeight(.bold)
			   .foregroundColor(isWinning ? .green : .primary)
		 }
	  }
	  .frame(maxWidth: .infinity)
   }
}
