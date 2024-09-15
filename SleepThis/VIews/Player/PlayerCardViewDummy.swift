import SwiftUI

struct PlayerCardViewDummy: View {
   let thisBackgroundColor: Color = .gpDeltaPurple  // Replace with your custom color definition

   var body: some View {
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
									   // Player Thumbnail
			if let url = URL(string: "https://sleepercdn.com/content/nfl/players/4984.jpg") {
			   AsyncImage(url: url) { image in
				  image
					 .resizable()
					 .scaledToFill()
					 .frame(width: 180, height: 180) // Adjust size as needed
					 .offset(x: -50)  // Shift the image to the left for overflow
			   } placeholder: {
				  Image(systemName: "person.crop.circle.fill")
					 .resizable()
					 .frame(width: 120, height: 120)
			   }
			}

			// Player Details
			VStack(alignment: .leading, spacing: 2) {
			   Text("Josh Allen")
				  .font(.title)
				  .foregroundColor(.white)
				  .bold()

			   Text("QB - BUF (17)")
				  .font(.subheadline)
				  .foregroundColor(.secondary)

			   Text("Round: ")
				  .font(.subheadline) +
			   Text("17")
				  .font(.title3)
				  .foregroundColor(.gpGreen) +
			   Text(".122")
				  .font(.footnote)
				  .foregroundColor(.gpBlue)


			}
			.padding(.leading, -80)  // Bleed
			.padding(.top, -40)

			Spacer()  // Spacer to fill remaining space
		 }
		 .padding()
	  }
	  .frame(minWidth: 0, maxWidth: 300, maxHeight: 130)  // Max height matches image height
	  .padding(.vertical, 4)
	  .padding(.horizontal, 4)
	  .clipped()  // Clip content inside the frame
	  .cornerRadius(25.0)
	  .preferredColorScheme(.dark)
   }
}

struct PlayerCardViewDummy_Previews: PreviewProvider {
   static var previews: some View {
	  PlayerCardViewDummy()
		 .previewLayout(.sizeThatFits)
		 .padding()
   }
}
