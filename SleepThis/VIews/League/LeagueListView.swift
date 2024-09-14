import SwiftUI

struct LeagueListView: View {
   @ObservedObject var leagueViewModel = LeagueViewModel()
   @ObservedObject var draftViewModel: DraftViewModel
   @State private var showAlert = false
   @State private var alertMessage = ""
   @State private var isLoading = false
   var managerID: String // Accept the userID (managerID)

   var body: some View {
	  NavigationView {
		 VStack {
			// Displaying the userID at the top
			let managerName = draftViewModel.managerName(for: managerID)
			Text("Leagues for \(managerName)")
			   .font(.title)
			   .padding()

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
		 .onAppear {
			// Fetch leagues for the passed userID
			isLoading = true
			leagueViewModel.fetchLeagues(userID: managerID)
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			   isLoading = false
			   if leagueViewModel.leagues.isEmpty {
				  alertMessage = "No leagues found for this user."
				  showAlert = true
			   }
			}
		 }
	  }
   }
}
