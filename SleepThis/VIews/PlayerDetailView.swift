import SwiftUI

struct PlayerDetailView: View {
   let player: PlayerModel
   let playerViewModel: PlayerViewModel

   var body: some View {
	  ScrollView {
		 VStack(alignment: .leading, spacing: 10) {
			PlayerInfoRowView(label: "Name", value: "\(player.firstName ?? "Unknown") \(player.lastName ?? "Unknown")")
			   .font(.title)
			   .padding(.top)

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
		 }
		 .padding()
		 .navigationTitle("\(player.firstName ?? "Player") \(player.lastName ?? "Details")")
	  }
   }



   @ViewBuilder
   private func playerInfoRow(label: String, value: String?) -> some View {
	  if let value = value, !value.isEmpty {
		 Text("\(label): \(value)")
	  }
   }
}
