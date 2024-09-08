import SwiftUI

struct RosterDetailView: View {
   let managerID: String
   let managerName: String
   let managerAvatarURL: URL?
   @ObservedObject var rosterViewModel: RosterViewModel
   let playerViewModel = PlayerViewModel()
   var playerSize = 50.0

   var body: some View {
	  ScrollView {
		 VStack(alignment: .leading, spacing: 10) {
			// Manager info: Avatar and Name
			HStack {
			   AsyncImage(url: managerAvatarURL) { image in
				  image.resizable()
					 .aspectRatio(contentMode: .fill)
					 .frame(width: playerSize, height: playerSize)
					 .clipShape(Circle())
			   } placeholder: {
				  Image(systemName: "person.crop.circle")
					 .resizable()
					 .frame(width: playerSize, height: playerSize)
			   }
			   VStack(alignment: .leading) {
				  Text(managerName)
					 .font(.title2)
//					 .bold()
//				  Text("Manager ID: \(managerID)")
//					 .font(.subheadline)
			   }
			}
			.padding(.bottom, 10)

			// Settings Section (4-column grid)
			if let settings = rosterViewModel.getManagerSettings(managerID: managerID) {
			   LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
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
					 Text("Pts For:")
						.font(.subheadline)
						.bold()
					 Text("\(settings.fpts)")
						.font(.subheadline)
						.foregroundColor(.gray)
				  }
				  VStack {
					 Text("Against")
						.font(.subheadline)
						.bold()
					 Text("\(settings.fptsAgainst ?? 0)")
						.font(.subheadline)
						.foregroundColor(.gray)
				  }
			   }
			   .padding(.top, 16)
			}

			// Pass the starters to the new StarterListView
			let starters = rosterViewModel.managerStarters(managerID: managerID)
			StarterListView(starters: starters, playerViewModel: playerViewModel)
		 }
		 .padding()
	  }
	  .navigationTitle("Roster Detail")
   }
}
