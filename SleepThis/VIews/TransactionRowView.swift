import SwiftUI

struct TransactionRowView: View {
   let thisTransaction: TransactionModel
   var thisUserViewModel: UserViewModel

   var body: some View {
	  HStack {
		 if let avatarURL = thisUserViewModel.user?.avatarURL {
			AsyncImage(url: avatarURL) { image in
			   image.resizable()
				  .aspectRatio(contentMode: .fill)
				  .frame(width: 40, height: 40)
				  .clipShape(Circle())
			} placeholder: {
			   Image(systemName: "person.crop.circle")
				  .resizable()
				  .frame(width: 40, height: 40)
			}
		 }
		 Text(thisUserViewModel.user?.display_name ?? "Unknown")
			.font(.headline)

		 VStack(alignment: .leading) {
			Text("Type: \(thisTransaction.type)")
			   .font(.headline)
			Text("Status: \(thisTransaction.status)")
			   .font(.subheadline)
		 }
	  }
   }
}
