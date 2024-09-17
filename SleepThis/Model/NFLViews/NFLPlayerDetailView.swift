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
			   .frame(height: 200)

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
				  Text(player.fullName)
					 .font(.title)
					 .foregroundColor(.white)
					 .bold()
					 .frame(maxWidth: .infinity, alignment: .leading)
					 .lineLimit(1)
					 .minimumScaleFactor(0.5)
					 .scaledToFit() +
				  Text(player.)

				  HStack {
					 Text("\(player.position?.displayName ?? "N/A") - \(player.team?.displayName ?? "N/A")")
						.font(.subheadline)
						.foregroundColor(.secondary)
				  }

				  if let coach = player.coach {
					 Text("Coach: \(coach.firstName) \(coach.lastName)")
						.font(.subheadline)
						.foregroundColor(.secondary)
				  }
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
						   .opacity(0.5)
					 @unknown default:
						EmptyView()
				  }
			   }
			   .padding(.bottom, -40)
			   .padding(.trailing, -40)
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
			   HStack {
				  Text("Height: \(height)")
					 .font(.subheadline)
				  Spacer()
				  Text("Weight: \(weight)")
					 .font(.subheadline)
			   }
			   .foregroundColor(.white)
			}

			if let age = player.age {
			   Text("Age: \(age)")
				  .font(.subheadline)
				  .foregroundColor(.white)
			}

//			if let college = player.college {
//			   Text("College: \(college.name)")
//				  .font(.subheadline)
//				  .foregroundColor(.white)
//			}
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
