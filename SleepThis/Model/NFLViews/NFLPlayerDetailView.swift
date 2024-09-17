import SwiftUI

struct NFLPlayerDetailView: View {
   let player: NFLRosterModel.NFLPlayer
   let nflRosterViewModel: NFLRosterViewModel

   var body: some View {
	  VStack {
		 ZStack {
			// Use the team's color for the background
			let teamColor = Color(hex: player.team?.color ?? "4b92db")
			RoundedRectangle(cornerRadius: 15)
			   .fill(LinearGradient(
				  gradient: Gradient(colors: [
					 teamColor,
					 .clear,
				  ]),
				  startPoint: .top,
				  endPoint: .bottom
			   ))
			   .shadow(radius: 4)

			HStack(alignment: .center) {
			   // Player Thumbnail
			   if let url = nflRosterViewModel.getPlayerImageURL(for: player) {
				  AsyncImage(url: url) { phase in
					 switch phase {
						case .empty:
						   Image(systemName: "person.crop.circle.fill")
							  .resizable()
							  .frame(width: 120, height: 120)
						case .success(let image):
						   image
							  .resizable()
							  .scaledToFill()
							  .frame(width: 180, height: 180)
							  .offset(x: -50) // Shift the image to the left for overflow
						case .failure:
						   Image(systemName: "person.crop.circle.fill")
							  .resizable()
							  .frame(width: 120, height: 120)
						@unknown default:
						   EmptyView()
					 }
				  }
			   }

			   // Player Details
			   VStack(alignment: .leading, spacing: 2) {
				  Text(player.fullName)
					 .font(.title)
					 .foregroundColor(.white)
					 .bold()

				  if let position = player.position, let team = player.team?.displayName {
					 HStack {
						Text("\(position) - \(team)")
						   .font(.subheadline)
						   .foregroundColor(.secondary)
						// Display team logo
						if let teamLogoURL = player.team?.logo {
						   AsyncImage(url: URL(string: teamLogoURL)) { phase in
							  switch phase {
								 case .empty:
									Image(systemName: "person.crop.circle.fill")
									   .resizable()
									   .frame(width: 30, height: 30)
								 case .success(let image):
									image
									   .resizable()
									   .frame(width: 30, height: 30)
									   .clipShape(Circle())
								 case .failure:
									Image(systemName: "person.crop.circle.fill")
									   .resizable()
									   .frame(width: 30, height: 30)
								 @unknown default:
									EmptyView()
							  }
						   }
						}
					 }
				  }

				  if let height = player.displayHeight, let weight = player.displayWeight {
					 HStack {
						Text("Height: \(height)")
						   .font(.subheadline)
						   .foregroundColor(.white)

						Text("Weight: \(weight)")
						   .font(.subheadline)
						   .foregroundColor(.gpGreen)
					 }
				  }

				  if let age = player.age {
					 HStack {
						Text("Age: \(age)")
						   .font(.subheadline)
						   .foregroundColor(.white)
					 }
				  }

				  // Display the coach's full name if available
				  if let coach = player.coach?.first {
					 Text("Coach: \(coach.firstName) \(coach.lastName)")
						.font(.subheadline)
						.foregroundColor(.secondary)
				  }
			   }
			   .padding(.leading, -80) // Bleed the text into the image
			   .padding(.top, -40)

			   Spacer() // Spacer to fill remaining space
			}
			.padding()
		 }
		 .frame(minWidth: 0, maxWidth: 340, maxHeight: 150) // Max height matches image height
		 .padding(.vertical, 4)
		 .padding(.horizontal, 4)
		 .clipped() // Clip content inside the frame
		 .cornerRadius(25.0)

		 Spacer()
	  }
	  .preferredColorScheme(.dark)
	  .navigationTitle(player.fullName)
	  .onAppear {
		 // Debug print for team and coach
		 print("Team: \(String(describing: player.team?.displayName))")
		 if let coach = player.coach?.first {
			print("Coach: \(coach.firstName) \(coach.lastName)")
		 } else {
			print("Coach: No coach data available")
		 }
	  }
   }
}
