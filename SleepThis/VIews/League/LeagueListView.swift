import SwiftUI

struct LeagueListView: View {
   @StateObject var leagueViewModel = LeagueViewModel()
   @ObservedObject var draftViewModel: DraftViewModel
   @State private var showAlert = false
   @State private var alertMessage = ""
   @State private var isLoading = false
   var managerID: String

   init(managerID: String, draftViewModel: DraftViewModel) {
	  self.managerID = managerID
	  self.draftViewModel = draftViewModel

	  // Trigger fetching manager's details right away
	  draftViewModel.fetchManagerDetails(managerID: managerID)
   }

   var body: some View {
	  NavigationStack {
		 VStack {
			// Displaying the userID at the top
			let managerName = draftViewModel.managerName(for: managerID)
			VStack {
			   Text("\(managerName)")
				  .font(.title)
				  .foregroundColor(.gpBlue)
				  .padding()
				  .frame(maxWidth: .infinity)
				  .lineLimit(1)
				  .minimumScaleFactor(0.5)
				  .scaledToFit()
			}
			VStack {
			   Text("Leagues")
				  .font(.title3)
				  .frame(maxWidth: .infinity, alignment: .center)
				  .foregroundColor(.gpBlue2)
				  .padding(.top, -30)
			}

			if isLoading {
			   ProgressView("Loading Leagues...")
				  .padding()
			} else {
			   List(leagueViewModel.leagues) { league in
				  NavigationLink(destination: LeagueDetailView(league: league)) { // Pass the LeagueModel object here
					 LeagueRowView(league: league)
				  }
			   }
			   .listStyle(PlainListStyle())
			}
		 }
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
