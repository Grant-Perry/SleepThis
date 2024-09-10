import SwiftUI


struct NFLPlayerDetailView: View {
   let player: NFLRosterModel.NFLPlayer
   let nflRosterViewModel: NFLRosterViewModel

   var body: some View {
	  ScrollView {
		 VStack(alignment: .leading, spacing: 16) {
			// Player Large Image
			AsyncImage(url: nflRosterViewModel.getPlayerImageURL(for: player)) { image in
			   image.resizable()
				  .aspectRatio(contentMode: .fit)
				  .frame(width: 200, height: 200)
				  .clipShape(Circle())
			} placeholder: {
			   Image(systemName: "person.crop.circle.fill")
				  .resizable()
				  .aspectRatio(contentMode: .fit)
				  .frame(width: 200, height: 200)
			}
			.padding(.bottom)

			Text(player.fullName)
			   .font(.largeTitle)
			   .fontWeight(.bold)

			if let height = player.displayHeight {
			   Text("Height: \(height)")
				  .font(.subheadline)
			}

			if let weight = player.displayWeight {
			   Text("Weight: \(weight)")
				  .font(.subheadline)
			}

			if let age = player.age {
			   Text("Age: \(age)")
				  .font(.subheadline)
			}

			if let college = player.college?.name {
			   Text("College: \(college)")
				  .font(.subheadline)
			}

			Spacer()
		 }
		 .padding()
	  }
	  .navigationTitle(player.fullName)
   }
}
