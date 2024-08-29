import SwiftUI

struct PlayerDetailView: View {
   let player: PlayerModel
   let playerViewModel: PlayerViewModel

   var body: some View {
	  ScrollView {
		 VStack(alignment: .leading, spacing: 10) {

			playerInfoRow(label: "Name", value: "\(player.firstName ?? "") \(player.lastName ?? "")")
			playerInfoRow(label: "ID", value: player.id)
			playerInfoRow(label: "Team", value: player.team)
			playerInfoRow(label: "Position", value: player.position)
			playerInfoRow(label: "Age", value: player.age?.description)
			playerInfoRow(label: "Height", value: player.height)
			playerInfoRow(label: "Weight", value: player.weight)
			playerInfoRow(label: "Status", value: player.status)
			playerInfoRow(label: "College", value: player.college)
			playerInfoRow(label: "Birth Country", value: player.birthCountry)
			playerInfoRow(label: "Years Experience", value: player.yearsExp?.description)
			playerInfoRow(label: "Fantasy Positions", value: player.fantasyPositions?.joined(separator: ", "))
			playerInfoRow(label: "Number", value: player.number?.description)
			playerInfoRow(label: "Depth Chart Position", value: player.depthChartPosition)
			playerInfoRow(label: "Depth Chart Order", value: player.depthChartOrder?.description)

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
