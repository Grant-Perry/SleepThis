import SwiftUI

struct MatchupView: View {
   @StateObject private var playerViewModel = PlayerViewModel()
   @State private var weekNumber: String = "1" // Default to week 1

   var body: some View {
	  NavigationView {
		 VStack {
			if playerViewModel.isLoading {
			   ProgressView("LOADING DATA...")
				  .padding()
				  .onAppear {
					 print("Loading data...")
				  }
			}

			HStack {
			   if let cacheAge = playerViewModel.cacheAgeDescription,
				  let cacheSize = playerViewModel.cacheSize {
				  Text("\(cacheAge) \(cacheSize)")
					 .font(.caption)
					 .onAppear {
						print("Cache age and size: \(cacheAge) \(cacheSize)")
					 }
			   }
			   Spacer()
			   Button(action: {
				  print("Reload cache button tapped.")
				  playerViewModel.reloadCache()
			   }) {
				  Image(systemName: "arrow.clockwise.circle.fill")
					 .font(.title2)
			   }
			}
			.padding()

			HStack {
			   TextField("Enter Week Number", text: $weekNumber)
				  .keyboardType(.numberPad)
				  .textFieldStyle(RoundedBorderTextFieldStyle())
				  .frame(width: 100)
			   Button(action: {
				  print("Fetching matchups for week: \(weekNumber)")
				  playerViewModel.fetchMatchups(week: Int(weekNumber) ?? 1)
			   }) {
				  Text("Go")
			   }
			   .disabled(weekNumber.isEmpty)
			}
			.padding()

			if !playerViewModel.matchups.isEmpty {
			   List(playerViewModel.matchups) { matchup in
				  NavigationLink(destination: MatchupDetailView(matchup: matchup, playerViewModel: playerViewModel)) {
					 VStack(alignment: .leading) {
						Text("Matchup ID: \(matchup.matchup_id)")
						   .font(.headline)
						Text("Points: \(matchup.points)")
					 }
				  }
			   }
			   .onAppear {
				  print("Matchups loaded: \(playerViewModel.matchups.count) matchups")
			   }
			} else if let errorMessage = playerViewModel.errorMessage {
			   Text("Error: \(errorMessage)")
				  .foregroundColor(.red)
				  .onAppear {
					 print("Error fetching data: \(errorMessage)")
				  }
			} else {
			   Text("No matchups data available.")
				  .onAppear {
					 print("No matchups data available.")
				  }
			}
		 }
		 .navigationTitle("Matchups")
		 .onAppear {
			print("MatchupView appeared.")
		 }
	  }
   }
}
