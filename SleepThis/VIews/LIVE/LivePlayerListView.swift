import SwiftUI

struct LivePlayerListView: View {
   @StateObject var liveViewModel = LivePlayerViewModel()

   var body: some View {
	  NavigationView {
		 Group {
			if liveViewModel.isLoading {
			   ProgressView("Loading players...") // Loading indicator
			} else if let errorMessage = liveViewModel.errorMessage {
			   VStack {
				  Text("Error: \(errorMessage)")
					 .foregroundColor(.red)
					 .multilineTextAlignment(.center)
					 .padding()
				  Button("Retry") {
					 liveViewModel.loadData()
				  }
			   }
			} else {
			   List(liveViewModel.players, id: \.id) { player in
				  NavigationLink(destination: LivePlayerDetailView(player: player)) {
					 HStack {
						AsyncImage(url: URL(string: "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/\(player.id ?? 0).png")) { phase in
						   switch phase {
							  case .empty:
								 ProgressView()
									.frame(width: 75, height: 75)
							  case .success(let image):
								 image
									.resizable()
									.scaledToFit()
									.frame(width: 75, height: 75)
									.clipShape(Circle())
							  case .failure:
								 Image(systemName: "person.crop.circle.fill")
									.resizable()
									.frame(width: 75, height: 75)
							  @unknown default:
								 EmptyView()
						   }
						}
						Text(player.fullName ?? "Unknown Player")
						   .font(.headline)
					 }
				  }
			   }
			}
		 }
		 .navigationTitle("Live Players")
		 .onAppear {
			// Only load data if the players array is empty (data has not been loaded yet)
			if liveViewModel.players.isEmpty {
			   liveViewModel.loadData()
			}
		 }
	  }
   }
}
