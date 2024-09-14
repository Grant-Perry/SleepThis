import SwiftUI

struct LeagueListView: View {
   @ObservedObject var leagueViewModel = LeagueViewModel()
   @State private var userID: String = AppConstants.sleeperID
   @State private var showAlert = false
   @State private var alertMessage = ""
   @State private var isLoading = false

   var body: some View {
	  NavigationView {
		 VStack {
			// Input field for Sleeper ID
			HStack {
			   TextField("Enter Sleeper ID", text: $userID)
				  .textFieldStyle(RoundedBorderTextFieldStyle())
				  .padding(.horizontal)

			   Button(action: {
				  if userID.isEmpty {
					 alertMessage = "Please enter a valid Sleeper ID."
					 showAlert = true
				  } else {
					 isLoading = true
					 leagueViewModel.fetchLeagues(userID: userID)
					 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
						isLoading = false
						if leagueViewModel.leagues.isEmpty {
						   alertMessage = "No leagues found for this user."
						   showAlert = true
						}
					 }
				  }
			   }) {
				  Image(systemName: "magnifyingglass")
					 .font(.title)
			   }
			   .padding(.trailing)
			}
			.padding(.top)

			if isLoading {
			   ProgressView("Loading Leagues...")
				  .padding()
			} else {
			   List(leagueViewModel.leagues) { league in
				  NavigationLink(destination: LeagueDetailView(leagueID: league.leagueID, draftID: league.draftID ?? AppConstants.draftID)) {
					 LeagueRowView(league: league)
				  }
			   }
			   .listStyle(PlainListStyle())
			}
		 }
		 .navigationTitle("Your Leagues")
		 .alert(isPresented: $showAlert) {
			Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
		 }
	  }
	  .onAppear {
		 // Fetch leagues for default user ID
		 leagueViewModel.fetchLeagues(userID: userID)
	  }
   }
}
