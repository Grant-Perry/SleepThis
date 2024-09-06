import SwiftUI

struct RosterRowView: View {
   let roster: RosterModel
   @ObservedObject var draftViewModel: DraftViewModel
   let backgroundColor: Color

   var body: some View {
	  HStack {
		 // Display the manager's avatar
		 if let avatarURL = draftViewModel.managerAvatar(for: roster.ownerID) {
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
		 } else {
			Image(systemName: "person.crop.circle")
			   .resizable()
			   .frame(width: 50, height: 50)
		 }

		 // Display the manager's name and Owner ID
		 VStack(alignment: .leading) {
			Text(draftViewModel.managerName(for: roster.ownerID))
			   .font(.title2)
			   .bold()
			Text("Owner ID: \(roster.ownerID)")
			   .font(.subheadline)
		 }
	  }
	  .padding()
	  .background(
		 LinearGradient(gradient: Gradient(colors: [backgroundColor.opacity(0.8), .clear]),
						startPoint: .leading,
						endPoint: .trailing)
		 .cornerRadius(8)
	  )
	  .foregroundColor(.black)
   }
}
