import SwiftUI

struct TransactionRowView: View {
   let transaction: TransactionModel
   @ObservedObject var userViewModel: UserViewModel

   var body: some View {
	  HStack {
		 if let avatarURL = userViewModel.user?.avatarURL {
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
		 Text(userViewModel.user?.display_name ?? "Unknown")
			.font(.headline)

		 VStack(alignment: .leading) {
			Text("Type: \(transaction.type)")
			   .font(.headline)
			Text("Status: \(transaction.status)")
			   .font(.subheadline)
		 }
	  }
   }
}
