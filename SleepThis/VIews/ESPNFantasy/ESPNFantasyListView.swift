//import SwiftUI
//
//struct ESPNFantasyListView: View {
//   @ObservedObject var espnFantasyViewModel = ESPNFantasyViewModel()
//   @State private var selectedWeek = 1 // Default to week 1
//
//   var body: some View {
//	  VStack {
//		 // Pulldown picker for week selection
//		 Picker("Select Week", selection: $selectedWeek) {
//			ForEach(1..<17) { week in
//			   Text("Week \(week)").tag(week)
//			}
//		 }
//		 .pickerStyle(MenuPickerStyle())
//		 .onChange(of: selectedWeek) { _ in
//			espnFantasyViewModel.fetchFantasyData(forWeek: selectedWeek)
//		 }
//		 .padding()
//
//		 if espnFantasyViewModel.isLoading {
//			ProgressView("Loading matchups...")
//		 } else if let errorMessage = espnFantasyViewModel.errorMessage {
//			Text("Error: \(errorMessage)")
//		 } else {
//			// Display matchups in a horizontal TabView
//			TabView {
//			   if let schedule = espnFantasyViewModel.espnFantasyModel?.schedule {
//				  ForEach(schedule, id: \.id) { matchup in
//					 VStack(alignment: .leading) {
//						Text("Matchup \(matchup.id)").font(.headline)
//						HStack {
//						   if let awayTeam = espnFantasyViewModel.getTeam(for: matchup.away.teamId) {
//							  ESPNTeamView(team: awayTeam, isWinner: matchup.winner == "AWAY")
//						   }
//						   Spacer()
//						   if let homeTeam = espnFantasyViewModel.getTeam(for: matchup.home.teamId) {
//							  ESPNTeamView(team: homeTeam, isWinner: matchup.winner == "HOME")
//						   }
//						}
//					 }
//					 .padding()
//				  }
//			   }
//			}
//			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)) // Horizontal tab view
//		 }
//	  }
//	  .onAppear {
//		 espnFantasyViewModel.fetchFantasyData(forWeek: selectedWeek) // Fetch data for the selected week
//	  }
//   }
//}
