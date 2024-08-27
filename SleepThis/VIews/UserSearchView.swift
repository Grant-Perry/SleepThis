import SwiftUI

struct UserSearchView: View {
    var userViewModel = UserViewModel()
   @State private var userLookup: String = ""

   var body: some View {
	  NavigationStack {
		 VStack {
			if userViewModel.isLoading {
			   ProgressView("LOADING DATA...")
				  .padding()
			}

			HStack {
			   TextField("Enter Username or User ID", text: $userLookup)
				  .textFieldStyle(RoundedBorderTextFieldStyle())
				  .padding(.horizontal)

			   Button(action: {
				  userViewModel.fetchUser(by: userLookup) {
					 // Handle any additional UI updates after fetching the user
				  }
			   }) {
				  Image(systemName: "plus.magnifyingglass")
					 .font(.title2)
			   }
			   .disabled(userLookup.isEmpty)
			   .padding(.trailing)
			}
			.padding()

			if let user = userViewModel.user {
			   HStack {
				  if let avatarURL = user.avatarURL {
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

				  VStack(alignment: .leading, spacing: 10) {
					 Text("Username: \(user.username)")
					 Text("Display Name: \(user.display_name ?? "Unknown")")
				  }
			   }
			   .padding()
			} else if let errorMessage = userViewModel.errorMessage {
			   Text("Error: \(errorMessage)")
				  .foregroundColor(.red)
				  .padding()
			} else {
			   Text("No user data available.")
				  .padding()
			}
		 }
		 .navigationTitle("User Lookup")
	  }
   }
}
