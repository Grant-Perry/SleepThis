import SwiftUI

struct RosterDetailView: View {
   let managerID: String
   @ObservedObject var rosterViewModel: RosterViewModel
   let playerViewModel = PlayerViewModel()
   let draftViewModel = DraftViewModel()

   var body: some View {
	  ScrollView {
		 VStack(alignment: .leading, spacing: 10) {
			// Manager info: Avatar and Name
			if let manager = rosterViewModel.rosters.first(where: { $0.ownerID == managerID }) {
			   HStack {
				  let avatarURL = URL(string: "https://sleepercdn.com/avatars/thumbs/\(manager.ownerID).jpg")
				  AsyncImage(url: avatarURL) { image in
					 image.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: 50, height: 50)
						.clipShape(Circle())
				  } placeholder: {
					 Image(systemName: "person.crop.circle")
						.resizable()
						.frame(width: 50, height: 50)
				  }
				  VStack(alignment: .leading) {
					 Text(draftViewModel.managerName(for: manager.ownerID))
						.font(.title2)
						.bold()
					 Text("Manager ID: \(manager.ownerID)")
						.font(.subheadline)
				  }
			   }
			   .padding(.bottom, 10)
			}

			// Settings Section (4-column grid)
			if let settings = rosterViewModel.getManagerSettings(managerID: managerID) {
			   LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
				  // Adjust properties based on RosterSettings
				  VStack {
					 Text("Wins:")
						.font(.subheadline)
						.bold()
					 Text("\(settings.wins)")
						.font(.subheadline)
						.foregroundColor(.gray)
				  }
				  VStack {
					 Text("Losses:")
						.font(.subheadline)
						.bold()
					 Text("\(settings.losses)")
						.font(.subheadline)
						.foregroundColor(.gray)
				  }
				  VStack {
					 Text("Points For:")
						.font(.subheadline)
						.bold()
					 Text("\(settings.fpts)")  // Corrected field from JSON
						.font(.subheadline)
						.foregroundColor(.gray)
				  }
				  VStack {
					 Text("Points Against:")
						.font(.subheadline)
						.bold()
//					 Text("\(settings.fpts)")  // Corrected field from JSON
//						.font(.subheadline)
//						.foregroundColor(.gray)
				  }
				  // Add more properties from RosterSettings as needed
			   }
			   .padding(.top, 16)
			}

			// Starters Section
			VStack(alignment: .leading, spacing: 10) {
			   Text("Starters")
				  .font(.title2)
				  .bold()
				  .padding(.top, 20)

			   ForEach(rosterViewModel.managerStarters(managerID: managerID), id: \.self) { starterID in
				  HStack {
					 if let url = URL(string: "https://sleepercdn.com/content/nfl/players/\(starterID).jpg") {
						AsyncImage(url: url) { image in
						   image.resizable()
							  .aspectRatio(contentMode: .fit)
							  .frame(width: 50, height: 50)
							  .clipShape(Circle())
						} placeholder: {
						   Image(systemName: "person.crop.circle")
							  .resizable()
							  .frame(width: 50, height: 50)
						}
					 }
					 VStack(alignment: .leading) {
						Text("Player Name")  // Replace with actual player name
						   .font(.headline)
						Text("Position, Team")  // Replace with actual player position and team
						   .font(.subheadline)
					 }
				  }
				  .padding(.vertical, 8)
			   }
			}
		 }
		 .padding()
	  }
	  .navigationTitle("Roster Detail")
	  .onAppear {
		 rosterViewModel.fetchRoster()
	  }
   }
}
