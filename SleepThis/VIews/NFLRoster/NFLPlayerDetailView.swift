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
			   // MARK: Player Image
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

			   Spacer() // Push the content to the right
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
			   .padding(.trailing, -22)
			}

			// MARK: Jersey Number Overlay on the Far Right
			VStack {
			   ZStack(alignment: .topTrailing) {
				  // Text for "# .top .trailing"
				  Text("#")
					 .font(.system(size: 28, weight: .light))
					 .foregroundColor(teamColor.adjustBrightness(by: 0.75))
					 .padding(.trailing, 5)
					 .padding(.top, 10)
				  // Jersey number
				  Text(player.jersey ?? "")
					 .font(.system(size: 85, weight: .bold))
					 .italic()
					 .foregroundColor(teamColor.adjustBrightness(by: 0.5))
					 .opacity(0.35)
					 .padding(.trailing, 10)
			   }
			   .offset(x: -10, y: -100)  // Move the jersey number further to the top right
			}

			// MARK: Player Name Overlay on Top
			VStack {
			   Text(player.fullName)
				  .font(.system(size: 48))
				  .foregroundColor(teamColor.blended(withFraction: 0.55, of: .white))
				  .bold()
				  .lineLimit(1)
				  .minimumScaleFactor(0.5)
				  .padding(.trailing, 20) // Add trailing padding
				  .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
			}
			.offset(x: 10, y: -100) // Adjust this to position the name across the ZStack

			//MARK: Position
			HStack {
			   Text(player.positionAbbreviation ?? "N/A")
				  .font(.headline)
//				  .foregroundColor(teamColor.blended(withFraction: 0.65, of: .white))
				  .foregroundColor(.white)
				  .bold()
				  .padding(.leading, 110)
				  .padding(.bottom,	60)
			   Spacer()
			   //					 Text("\(player.team?.displayName ?? "N/A")")
			   //						.font(.footnote)
			   //						.foregroundColor(teamColor.adjustBrightness(by: 0.75))
			}
			.opacity(0.5)
			.offset(y: -25)


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
   }
}
