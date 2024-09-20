import SwiftUI

struct PlayerDetailView: View {
   let player: PlayerModel
   let playerViewModel: PlayerViewModel
   var playerSize = 350.0
   let round: Int? // Add optional round parameter
   let pickNo: Int? // Add optional pickNo parameter

   var body: some View {
	  ScrollView {
		 VStack(alignment: .leading, spacing: 10) {
			VStack {
			   if let url = URL(string: "https://sleepercdn.com/content/nfl/players/\(player.id).jpg") {
				  AsyncImage(url: url) { image in
					 image
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: playerSize, height: playerSize)
						.padding(.top, -20) // Move the image slightly up
				  } placeholder: {
					 Image(systemName: "person.crop.circle.fill")
						.resizable()
						.frame(width: playerSize, height: playerSize)
				  }
			   }
			   Text("\(player.firstName ?? "Unknown") \(player.lastName ?? "Unknown")")
				  .font(.title)
				  .fontWeight(.bold)
				  .padding(.top, -30) // Adjust the spacing between the image and the header
				  .multilineTextAlignment(.center)
			}
			.frame(maxWidth: .infinity) // Center the content

			VStack(alignment: .leading, spacing: 5) {
			   PlayerInfoRowView(label: "ID", value: player.id)
			   PlayerInfoRowView(label: "Team", value: player.team)
			   PlayerInfoRowView(label: "Position", value: player.position)
			   PlayerInfoRowView(label: "Age", value: player.age?.description)
			   PlayerInfoRowView(label: "Height", value: player.height)
			   PlayerInfoRowView(label: "Weight", value: player.weight)
			   PlayerInfoRowView(label: "Status", value: player.status)
			   PlayerInfoRowView(label: "College", value: player.college)
			   PlayerInfoRowView(label: "Birth Country", value: player.birthCountry)
			   PlayerInfoRowView(label: "Years Experience", value: player.yearsExp?.description)
			   PlayerInfoRowView(label: "Fantasy Positions", value: player.fantasyPositions?.joined(separator: ", "))
			   PlayerInfoRowView(label: "Number", value: player.number?.description)
			   PlayerInfoRowView(label: "Depth Chart Position", value: player.depthChartPosition?.description)
			   PlayerInfoRowView(label: "Depth Chart Order", value: player.depthChartOrder?.description)

			   // Add round and pick details if available
			   if let round = round, let pickNo = pickNo {
				  PlayerInfoRowView(label: "Drafted", value: "Round \(round), Pick \(pickNo)")
			   }
			}
			.padding(.top, -15) // Tighten up the spacing under the header
			.padding()
		 }
		 .padding(.top, 10)
	  }
	  .preferredColorScheme(.dark)
   }

   @ViewBuilder
   private func PlayerInfoRowView(label: String, value: String?) -> some View {
	  if let value = value, !value.isEmpty {
		 Text("\(label): \(value)")
	  }
   }
}


