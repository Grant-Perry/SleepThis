import SwiftUI

struct LeagueRowView: View {
   let league: LeagueModel
   var body: some View {
	  HStack {
		 if let avatar = league.avatar, let url = URL(string: "https://sleepercdn.com/avatars/\(avatar)") {
			AsyncImage(url: url) { image in
			   image.resizable()
				  .aspectRatio(contentMode: .fill)
				  .frame(width: 50, height: 50)
				  .clipShape(Circle())
			} placeholder: {
			   Image(systemName: "person.crop.circle")
				  .resizable()
				  .frame(width: 50, height: 50)
			}
		 } else {
			Image(systemName: "person.crop.circle")
			   .resizable()
			   .frame(width: 50, height: 50)
		 }
		 VStack(alignment: .leading) {
			Text(league.name)
			   .font(.headline)
			Text(league.leagueID)
			   .font(.footnote)
			Text("Season: \(league.season)")
			   .font(.subheadline)
			   .foregroundColor(.gray)
		 }
	  }
   }
}
