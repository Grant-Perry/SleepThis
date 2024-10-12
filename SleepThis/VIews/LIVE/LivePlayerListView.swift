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
						AsyncImage(url: URL(string: "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/\(player.id ?? 0).png&w=75&h=75")) { image in
						   image
							  .resizable()
							  .frame(width: 75, height: 75)
							  .clipShape(Circle())
						} placeholder: {
						   ProgressView()
							  .frame(width: 75, height: 75)
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
