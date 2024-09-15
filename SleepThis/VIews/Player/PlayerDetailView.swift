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

struct PlayerDetailView_Previews: PreviewProvider {
   static var previews: some View {
	  // Example data for preview
	  let examplePlayer = PlayerModel(
		 id: "4046",
		 firstName: "Patrick",
		 lastName: "Mahomes",
		 fullName: "Patrick Mahomes",
		 team: "KC",
		 position: "QB",
		 age: 28,
		 height: "6'3\"",
		 weight: "230",
		 status: "Active",
		 college: "Texas Tech",
		 birthCity: "Tyler",
		 birthState: "TX",
		 birthCountry: "USA",
		 birthDate: "1995-09-17",
		 yearsExp: 7,
		 highSchool: "Whitehouse",
		 fantasyPositions: ["QB"],
		 metadata: nil,
		 newsUpdated: nil,
		 number: 15,
		 depthChartPosition: "QB",
		 depthChartOrder: 1,
		 rookieYear: "2017",
		 statsId: "4046",
		 searchLastName: "mahomes",
		 searchFirstName: "patrick",
		 searchFullName: "patrickmahomes",
		 hashtag: "#PatrickMahomes-NFL-KC-15",
		 injuryStartDate: nil,
		 practiceParticipation: nil,
		 sportradarId: "",
		 fantasyDataId: 4046,
		 injuryStatus: nil,
		 yahooId: nil,
		 rotowireId: 13244,
		 rotoworldId: 11601,
		 espnId: "3139477",
		 searchRank: 1
	  )

	  let exampleViewModel = PlayerViewModel()

	  return PlayerDetailView(player: examplePlayer, playerViewModel: exampleViewModel, round: 1, pickNo: 10)
   }
}
