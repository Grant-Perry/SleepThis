import SwiftUI

struct ManagerRowView: View {
   let managerID: String
   @ObservedObject var draftViewModel: DraftViewModel
   let backgroundColor: Color

   var body: some View {
	  HStack {
		 if let avatarURL = draftViewModel.managerAvatar(for: managerID) {
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
			Text(draftViewModel.managerName(for: managerID))
			   .font(.title2)
			   .bold()
			if let draftSlot = draftViewModel.groupedPicks[managerID]?.first?.draft_slot
			   {
			   Text("Pick #:\(draftSlot)")
				  .font(.subheadline)
			} else {
			   Text("Pick #: N/A")
				  .font(.subheadline)
			}
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
