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
			   ZStack(alignment: .topLeading) {
				  // Jersey number
				  Text(player.jersey ?? "")
					 .font(.system(size: 115, weight: .bold))
					 .italic()
					 .foregroundColor(teamColor.adjustBrightness(by: 0.5))
					 .opacity(0.35)

	  // MARK: # symbol, positioned at the top leading corner
				  Text("#")
					 .font(.system(size: 55, weight: .light))
					 .foregroundColor(teamColor.adjustBrightness(by: 0.25))
					 .offset(x: -10, y:10)

			   }
			   .offset(x: 0, y: -70)
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

import SwiftUI

struct NFLPlayerDetailView_Previews: PreviewProvider {
   static var previews: some View {
	  NFLPlayerDetailView(player: sampleNFLPlayer)
		 .previewLayout(.sizeThatFits)
   }
}

// Sample data for preview
let sampleNFLPlayer = NFLRosterModel.NFLPlayer(
   uid: "12345",
   imageID: "4241479",
   firstName: "Tua",
   lastName: "Tagovailoa",
   fullName: "Tua Tagovailoa",
   displayName: "T. Tagovailoa",
   jersey: "99",
   weight: 220,
   displayWeight: "220 lbs",
   height: 6.2,
   displayHeight: "6'2\"",
   age: 28,
   position: NFLRosterModel.Position(name: "Quarterback", displayName: "QB", abbreviation: "QB"),
   college: NFLRosterModel.College(name: "University of Nowhere"),
   team: NFLRosterModel.Team(id: "1", abbreviation: "XYZ", displayName: "Sample Team", color: "008C96", logo: "https://a.espncdn.com/i/teamlogos/nfl/500/mia.png"),
   coach: NFLRosterModel.Coach(id: "c1", firstName: "Jane", lastName: "Doe", experience: 5),
   status: NFLRosterModel.PlayerStatus(id: "1", name: "Injured", type: "Status", abbreviation: "IR"),  // Sample status
   injuries: [NFLRosterModel.Injury(status: "IR", date: "2023-09-20")]  // Sample injury
)


