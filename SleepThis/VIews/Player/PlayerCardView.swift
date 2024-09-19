import SwiftUI

struct PlayerCardView: View {
   let playerModel: PlayerModel
   let thisBackgroundColor: Color // = .gpDeltaPurple  // Replace with your custom color definition
   var round: String
   var pick: String
   let managerName: String
   let managerAvatarURL: URL?

   var body: some View {
	  VStack {
		 ZStack {
			// Background card with a gradient
			RoundedRectangle(cornerRadius: 15)
			   .fill(LinearGradient(
				  gradient: Gradient(colors: [
					 thisBackgroundColor,
					 .clear,
				  ]),
				  startPoint: .top,
				  endPoint: .bottom
			   ))
			   .shadow(radius: 4)

			HStack(alignment: .center) {  // Center the image and text vertically
//MARK: Player Thumbnail
			   if let url = URL(string: "https://sleepercdn.com/content/nfl/players/\(playerModel.id).jpg") {
				  AsyncImage(url: url) { image in
					 image
						.resizable()
						.scaledToFill()
						.frame(width: 180, height: 180) // Adjust size as needed
						.offset(x: -50, y: 10)  // Shift the image to the left for overflow
					 .isOnIR(playerModel.injuryStatus ?? "", hXw: 180)
//					 .padding(.trailing, 10)
					 .offset(x: 10, y: -20)
				  } placeholder: {
					 Image(systemName: "person.crop.circle.fill")
						.resizable()
						.frame(width: 120, height: 120)
				  }
			   }

			   // Player Details
			   VStack(alignment: .leading, spacing: 2) {
				  Text("\(playerModel.firstName ?? "") \(playerModel.lastName ?? "")")
					 .font(.title)
					 .foregroundColor(.white)
					 .bold()

				  Text("\(playerModel.position ?? "") - \(playerModel.team ?? "") (\(playerModel.number ?? 0))")
					 .font(.subheadline)
					 .foregroundColor(.secondary)

				  // Display round and pick information
				  if round != "909" {   // 909 passed from PlayerSearchView - draft not applicable
					 HStack {
						Text("Round: ")
						   .font(.subheadline)
						   .foregroundColor(.white)

						Text("\(round)")
						   .font(.title3)
						   .foregroundColor(.gpGreen)

						Text(".\(pick)")
						   .font(.footnote)
						   .foregroundColor(.gpBlue)
					 }
				  }
			   }
			   .padding(.leading, -80)  // Bleed the text into the image
			   .padding(.top, -40)

			   Spacer()  // Spacer to fill remaining space
			}
			.padding()
		 }
		 .frame(minWidth: 0, maxWidth: 340, maxHeight: 150)  // Max height matches image height
		 .padding(.vertical, 4)
		 .padding(.horizontal, 4)
		 .clipped()  // Clip content inside the frame
		 .cornerRadius(25.0)

		 // Manager's avatar and name at the bottom
		 HStack {
			if let avatarURL = managerAvatarURL {
			   AsyncImage(url: avatarURL) { image in
				  image
					 .resizable()
					 .scaledToFill()
					 .frame(width: 40, height: 40)
					 .clipShape(Circle())
			   } placeholder: {
				  Image(systemName: "person.crop.circle.fill")
					 .resizable()
					 .frame(width: 40, height: 40)
			   }
			}

			Text(managerName)
			   .font(.headline)
			   .foregroundColor(.gray)
			   .bold()

			Text(" (original manager)")
			   .font(.footnote)
			   


			Spacer()
		 }
		 .padding(.top, 10)
		 .padding(.horizontal, 10)
	  }
	  .preferredColorScheme(.dark)
   }
}
