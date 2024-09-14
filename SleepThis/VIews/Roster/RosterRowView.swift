import SwiftUI

struct RosterRowView: View {
   let roster: RosterModel
   @StateObject var draftViewModel: DraftViewModel
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

		 VStack(alignment: .leading) {
			Text(draftViewModel.managerName(for: roster.ownerID))
			   .font(.title2)
			   .bold()

			Text("Owner ID: \(roster.ownerID)")
			   .font(.subheadline)
		 }

		 Spacer()
	  }
	  .padding()
	  .frame(maxWidth: .infinity)  // Ensures full width
	  .background(RoundedRectangle(cornerRadius: 8).fill(backgroundColor))  // Rounded corners with background
//	  .foregroundColor(.black)
   }
}
