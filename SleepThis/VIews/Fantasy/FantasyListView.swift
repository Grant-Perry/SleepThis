//import SwiftUI
//
//struct FantasyListView: View {
//   @ObservedObject var viewModel = FantasyViewModel()
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
//		 .onChange(of: selectedWeek) { newWeek in
//			viewModel.fetchFantasyData(forWeek: newWeek)
//		 }
//
//
//
//		 .padding()
//
//		 if viewModel.isLoading {
//			ProgressView("Loading matchups...")
//		 } else if let errorMessage = viewModel.errorMessage {
//			Text("Error: \(errorMessage)")
//		 } else {
//			// Display matchups in a horizontal TabView
//			TabView {
//			   ForEach(viewModel.matchups, id: \.id) { matchup in
//				  VStack(alignment: .leading) {
//					 Text("Matchup \(matchup.id)").font(.headline)
//
//					 HStack {
//						TeamView(team: matchup.away, isWinner: matchup.winner == "AWAY")
//						Spacer()
//						TeamView(team: matchup.home, isWinner: matchup.winner == "HOME")
//					 }
//				  }
//				  .padding()
//			   }
//			}
//			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)) // Horizontal tab view
//		 }
//	  }
//	  .onAppear {
//		 viewModel.fetchFantasyData(forWeek: selectedWeek) // Fetch data for the selected week
//	  }
//   }
//}
//
//struct TeamView: View {
//   let team: Fantasy.Team
//   let isWinner: Bool
//
//   var body: some View {
//	  VStack(alignment: .leading) {
//		 Text(team.teamName) // Display actual team name
//			.font(.title)
//			.foregroundColor(isWinner ? .green : .primary)
//		 Text("Total Points: \(team.totalPoints ?? 0, specifier: "%.2f")")
//			.font(.subheadline)
//
//		 ForEach(team.players ?? [], id: \.playerID) { player in
//			PlayerView(player: player)
//		 }
//	  }
//   }
//}
//
//struct PlayerView: View {
//   let player: Fantasy.Player
//
//   var body: some View {
//	  HStack {
//		 // Display player image using AsyncImage
//		 let playerID = player.playerID
//		 let imageUrl = URL(string: "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/\(playerID).png")
//
//		 AsyncImage(url: imageUrl) { phase in
//			switch phase {
//			   case .empty:
//				  Image(systemName: "person.crop.circle.fill")
//					 .resizable()
//					 .frame(width: 40, height: 40)
//			   case .success(let image):
//				  image
//					 .resizable()
//					 .scaledToFill()
//					 .frame(width: 40, height: 40)
//			   case .failure:
//				  Image(systemName: "person.crop.circle.fill")
//					 .resizable()
//					 .frame(width: 40, height: 40)
//			   @unknown default:
//				  EmptyView()
//			}
//		 }
//
//		 VStack(alignment: .leading) {
//			Text(player.fullName)
//			Text("Points: \(player.appliedStatTotal ?? 0, specifier: "%.2f")")
//			   .font(.subheadline)
//		 }
//	  }
//   }
//}
