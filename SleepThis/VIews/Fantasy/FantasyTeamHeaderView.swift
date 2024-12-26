import SwiftUI

struct FantasyTeamHeaderView: View {
   let managerName: String
   let score: Double
   let avatarURL: URL?
   let isWinning: Bool
   var fantasyViewModel: FantasyMatchupViewModel? = nil
   var rosterID: Int? = nil
   
   var body: some View {
	  VStack(spacing: 8) {
		 ZStack {
			// Avatar
			if let url = avatarURL {
			   AsyncImage(url: url) { image in
				  image
					 .resizable()
					 .aspectRatio(contentMode: .fill)
					 .frame(width: 40, height: 40)
					 .clipShape(Circle())
			   } placeholder: {
				  Image(systemName: "person.crop.circle.fill")
					 .resizable()
					 .frame(width: 40, height: 40)
					 .foregroundColor(.gray)
			   }
			} else {
			   Image(systemName: "person.crop.circle.fill")
				  .resizable()
				  .frame(width: 40, height: 40)
				  .foregroundColor(.gray)
			}
			
			if isWinning {
			   Circle()
				  .strokeBorder(Color.green, lineWidth: 2)
				  .frame(width: 44, height: 44)
			}
		 }
		 
		 VStack(spacing: 2) {
			Text(managerName)
			   .font(.system(size: 13))
			   .fontWeight(.medium)
			   .lineLimit(1)
			   .minimumScaleFactor(0.8)
			   .foregroundColor(.gpYellow)
			Text(String(format: "%.2f", score))
			   .font(.title3)
			   .fontWeight(.bold)
			   .foregroundColor(isWinning ? .green : .gpRedLight)
		 }
	  }
	  .frame(maxWidth: .infinity)
   }
}
