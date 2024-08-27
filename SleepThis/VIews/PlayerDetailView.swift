import SwiftUI

struct PlayerDetailView: View {
   let player: PlayerModel
   let playerViewModel: PlayerViewModel

   var body: some View {
	  ScrollView {
		 VStack(alignment: .leading, spacing: 10) {
			Text("Name: \(player.firstName ?? "Unknown") \(player.lastName ?? "Unknown")")
			   .font(.title)
			Text("ID: \(player.id)")
			Text("Team: \(player.team ?? "Unknown")")
			Text("Position: \(player.position ?? "Unknown")")
			Text("Age: \(player.age?.description ?? "Unknown")")
			Text("Height: \(player.height ?? "Unknown")") // Height is now directly stored in the correct format
			Text("Weight: \(player.weight ?? "Unknown")")
			Text("Status: \(player.status ?? "Unknown")")
			Text("College: \(player.college ?? "Unknown")")
			//			Text("Birth City: \(player.birthCity ?? "Unknown")")
			//			Text("Birth State: \(player.birthState ?? "Unknown")")
			Text("Birth Country: \(player.birthCountry ?? "Unknown")")
			//			Text("Birth Date: \(player.birthDate ?? "Unknown")")
			Text("Years Experience: \(player.yearsExp?.description ?? "Unknown")")
			//			Text("High School: \(player.highSchool ?? "Unknown")")
			Text("Fantasy Positions: \(player.fantasyPositions?.joined(separator: ", ") ?? "Unknown")")
			//			Text("Metadata: \(player.metadata?.map { "\($0.key): \($0.value)" }.joined(separator: ", ") ?? "None")")
			//			Text("News Updated: \(player.newsUpdated?.description ?? "Unknown")")
			Text("Number: \(player.number?.description ?? "Unknown")")
			Text("Depth Chart Position: \(player.depthChartPosition?.description ?? "Unknown")")
			Text("Depth Chart Order: \(player.depthChartOrder?.description ?? "Unknown")")
			//			Text("Rookie Year: \(player.rookieYear?.description ?? "Unknown")")
		 }
		 .padding()
		 .navigationTitle("\(player.firstName ?? "Player") \(player.lastName ?? "Details")")
	  }
   }
}
