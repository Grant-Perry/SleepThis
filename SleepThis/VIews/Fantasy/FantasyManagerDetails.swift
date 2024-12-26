import SwiftUI

struct FantasyManagerDetails: View {
   let managerName: String
   let managerRecord: String
   let score: Double
   let isWinning: Bool
   let avatarURL: URL?

   var body: some View {
	  VStack(spacing: 4) {
		 // Avatar section
		 ZStack {
			if let url = avatarURL {
			   AsyncImage(url: url) { image in
				  image
					 .resizable()
					 .aspectRatio(contentMode: .fill)
					 .frame(width: 40, height: 40)
					 .clipShape(Circle())
			   } placeholder: {
				  Image(systemName: "person.crop.circle.fill")
					 .resizable()
					 .frame(width: 40, height: 40)
					 .foregroundColor(.gray)
			   }
			} else {
			   Image(systemName: "person.crop.circle.fill")
				  .resizable()
				  .frame(width: 40, height: 40)
				  .foregroundColor(.gray)
			}

			if isWinning {
			   Circle()
				  .strokeBorder(Color.green, lineWidth: 2)
				  .frame(width: 44, height: 44)
			}
		 }

		 // Manager name and record
		 Text(managerName)
			.font(.system(size: 16, weight: .semibold))
			.foregroundColor(.gpYellow)
			.lineLimit(1)
			.minimumScaleFactor(0.8)

		 Text(managerRecord)
			.font(.system(size: 10, weight: .medium))
			.foregroundColor(.gray)

		 // Score
		 Text(String(format: "%.2f", score))
			.font(.title3)
			.fontWeight(.bold)
			.foregroundColor(isWinning ? .green : .gpRedLight)
	  }
	  .frame(maxWidth: .infinity)
   }
}
