import SwiftUI

struct NFLPlayerDetailView: View {
   let player: NFLRosterModel.NFLPlayer

   var body: some View {
	  VStack {
		 ZStack(alignment: .bottomTrailing) {
			let teamColor = Color(hex: player.team?.color ?? "4b92db")

			RoundedRectangle(cornerRadius: 15)
			   .fill(LinearGradient(
				  gradient: Gradient(colors: [teamColor, .clear]),
				  startPoint: .top,
				  endPoint: .bottom
			   ))
			   .shadow(radius: 4)
			   .frame(height: 180)

			HStack(alignment: .center) {
			   // Player Image
			   if let playerImageUrl = player.imageUrl {
				  AsyncImage(url: playerImageUrl) { phase in
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
							  .offset(x: -50)
							  .clipped()
						case .failure:
						   Image(systemName: "person.crop.circle.fill")
							  .resizable()
							  .frame(width: 180, height: 180)
						@unknown default:
						   EmptyView()
					 }
				  }
			   } else {
				  Image(systemName: "person.crop.circle.fill")
					 .resizable()
					 .frame(width: 180, height: 180)
			   }

			   VStack(alignment: .leading, spacing: 8) {
 // MARK: Player Name
				  HStack {
					 Text(player.fullName)
						.font(.title)
						.foregroundColor(teamColor.blended(withFraction: 0.55, of: .white))
						.bold()
						.frame(maxWidth: .infinity, alignment: .leading)
						.lineLimit(1)
						.minimumScaleFactor(0.5)

					 // Player's jersey number (large and offset to bleed over the name)
					 ZStack(alignment: .topTrailing) {
						// Text for "# .top .trailing"
						Text("#")
						   .font(.system(size: 28, weight: .light))
						   .foregroundColor(teamColor.adjustBrightness(by: 0.75))
						   .padding(.top, 15)
						   .padding(.trailing, 105)
//						   .offset(x: -110, y: 20)  // Adjust the offset to control its position relative to the jersey number
// MARK: Jersey
						Text(player.jersey ?? "")
						   .font(.system(size: 85, weight: .bold))
					 }
					 .italic()
					 .foregroundColor(teamColor.adjustBrightness(by: 0.5))
					 .opacity(0.35)
				  }
//MARK: Position
				  HStack {
					 Text(player.positionAbbreviation ?? "N/A")
						.font(.headline)
						.foregroundColor(teamColor.blended(withFraction: 0.85, of: .white))
						.bold()
						.offset(y: -20)
					 Spacer()
//					 Text("\(player.team?.displayName ?? "N/A")")
//						.font(.footnote)
//						.foregroundColor(teamColor.adjustBrightness(by: 0.75))
				  }
				  .opacity(0.5)
				  .offset(y: -25)

			   }
			   .padding(.leading, -80)
			   .padding(.top, -40)

			   Spacer()
			}
			.padding()

			// Team Logo
			if let teamLogoURL = URL(string: player.team?.logo ?? "") {
			   AsyncImage(url: teamLogoURL) { phase in
				  switch phase {
					 case .empty:
						Image(systemName: "photo")
						   .resizable()
						   .frame(width: 180, height: 180)
						   .opacity(0.5)
					 case .success(let image):
						image
						   .resizable()
						   .frame(width: 180, height: 180)
						   .offset(x: -15, y: 18)
						   .opacity(0.5)
						   .clipped()
					 case .failure:
						Image(systemName: "photo")
						   .resizable()
						   .frame(width: 180, height: 180)
						   .opacity(0.35)
					 @unknown default:
						EmptyView()
				  }
			   }
			   .padding(.bottom, -40)
			   .padding(.trailing, -30)
			}
		 }
		 .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 200)
		 .padding(.vertical, 4)
		 .padding(.horizontal, 4)
		 .clipped()
		 .cornerRadius(25.0)

		 // Player Details
		 VStack(alignment: .leading, spacing: 10) {
			if let height = player.displayHeight, let weight = player.displayWeight {
			   HStack(spacing: 2) {
				  Text("Height: \(height)")
				  Spacer()
				  Text("Weight: \(weight)")
			   }
			   .foregroundColor(.white)
			   .font(.footnote)
			}

			if let age = player.age,
			   let coachFirstName = player.coach?.firstName,
			   let coachLastName = player.coach?.lastName {

			   let coach = "\(coachFirstName) \(coachLastName)"
			   HStack(spacing: 2) {
				  Text("Age: \(age)")
				  Spacer()
				  Text("Coach: \(coach)")
			   }
			   .foregroundColor(.white)
			   .font(.footnote)
			}

		 }
		 .padding()
		 .background(RoundedRectangle(cornerRadius: 15)
			.fill(Color.black.opacity(0.4)))
		 .padding()

		 Spacer()
	  }
	  .preferredColorScheme(.dark)
	  //	  .navigationTitle(player.fullName)
   }
}
