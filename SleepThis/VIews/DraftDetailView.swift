import SwiftUI

struct DraftDetailView: View {
   let draftPick: DraftModel

   var body: some View {
	  VStack(alignment: .leading, spacing: 15) {
		 Text("Manager: \(draftPick.managerName ?? "Unknown Manager")")
			.font(.title2)
			.padding(.top)

		 VStack(alignment: .leading) {
			if let url = URL(string: "https://sleepercdn.com/content/nfl/players/\(draftPick.player_id).jpg") {
			   AsyncImage(url: url) { image in
				  image.resizable()
					 .aspectRatio(contentMode: .fit)
					 .frame(width: 75, height: 75)
					 .clipShape(Circle())
			   } placeholder: {
				  Image(systemName: "person.crop.circle.fill")
					 .resizable()
					 .frame(width: 75, height: 75)
			   }
			}

			Text("\(draftPick.metadata?.first_name ?? "Unknown") \(draftPick.metadata?.last_name ?? "Player")")
			   .font(.headline)
			Text("Team: \(draftPick.metadata?.team ?? "Unknown Team")")
			Text("Position: \(draftPick.metadata?.position ?? "Unknown Position")")
			Text("Round: \(draftPick.round)")
			Text("Depth Chart Position: \(draftPick.metadata?.depth_chart_position ?? "Unknown")")
		 }
		 .padding(.leading, 10)

		 Divider()
	  }
	  .padding()
	  .navigationTitle("Draft Picks")
   }
}
