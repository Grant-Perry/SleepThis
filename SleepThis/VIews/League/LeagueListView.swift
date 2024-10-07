import SwiftUI

struct LeagueListView: View {
   @Environment(\.dismiss) var dismiss
   @StateObject var leagueViewModel = LeagueViewModel()
   @StateObject var draftViewModel: DraftViewModel
   @State private var showAlert = false
   @State private var alertMessage = ""
   @State private var isLoading = false
   @State private var searchLeagueID: String
   @State private var showNewLeagueList = false
   @State private var hasFetchedManagerDetails = false // Flag to track if manager details have been fetched
   var managerID: String

   init(managerID: String, draftViewModel: DraftViewModel, currentLeagueID: String? = nil) {
	  self.managerID = managerID
	  _draftViewModel = StateObject(wrappedValue: draftViewModel)
	  _searchLeagueID = State(initialValue: currentLeagueID ?? AppConstants.leagueID)
   }

   var body: some View {
	  NavigationView {
		 VStack {
			// Display the manager's name (fetchManagerDetails is triggered in onAppear)
			let managerName = draftViewModel.managerName(for: managerID)
			VStack {
			   Text("\(managerName.isEmpty ? "Unknown Manager" : managerName)")
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

			   HStack {
				  TextField("Search League ID", text: $searchLeagueID)
					 .padding(.vertical, 8)
					 .padding(.horizontal, 10)
					 .background(Color.gpDark1)
					 .cornerRadius(10)

				  Button(action: {
					 showNewLeagueList = true
				  }) {
					 Image(systemName: "magnifyingglass")
						.foregroundColor(.gray)
						.padding(.trailing, 10)
				  }
			   }
			   .padding(.horizontal)
			}

			if isLoading {
			   ProgressView("Loading Leagues...")
				  .padding()
			} else {
			   List(leagueViewModel.leagues) { league in
				  NavigationLink(destination: LeagueDetailView(league: league)) {
					 LeagueRowView(league: league)
				  }
			   }
			   .listStyle(PlainListStyle())
			}
		 }
		 .toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
			   Button(action: {
				  dismiss()
			   }) {
				  HStack {
					 Image(systemName: "chevron.left")
					 Text("Back")
				  }
				  .foregroundColor(.blue)
			   }
			}
		 }
		 .onAppear {
			if !hasFetchedManagerDetails {
			   hasFetchedManagerDetails = true
			   // Fetch manager details for the passed userID
			   isLoading = true
			   draftViewModel.fetchManagerDetails(managerID: managerID) { success in
				  if success {
					 print("[onAppear]: Manager details fetched successfully.")
					 // Fetch leagues for the userID
					 leagueViewModel.fetchLeagues(userID: managerID)
				  } else {
					 alertMessage = "Failed to load manager details."
					 showAlert = true
				  }
				  isLoading = false
			   }
			}
		 }
		 .alert(isPresented: $showAlert) {
			Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
		 }
		 .sheet(isPresented: $showNewLeagueList) {
			LeagueListView(
			   managerID: searchLeagueID, // Use the value from the text field
			   draftViewModel: DraftViewModel(leagueID: searchLeagueID) // Pass the leagueID from the search text
			)
		 }
	  }
   }
}
