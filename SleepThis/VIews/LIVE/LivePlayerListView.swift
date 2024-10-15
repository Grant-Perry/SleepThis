import SwiftUI
import Combine

struct LivePlayerListView: View {
   @StateObject var liveViewModel = LivePlayerViewModel()
   @State private var cancellable: AnyCancellable?

   var body: some View {
	  NavigationView {
		 VStack {
			// Refresh button
			HStack {
			   Spacer()
			   Button(action: {
				  refreshData()
			   }) {
				  Image(systemName: "arrow.clockwise.circle")
					 .font(.largeTitle)
					 .foregroundColor(.blue)
			   }
			   .padding()
			}

			// Player list content
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
						refreshData()
					 }
				  }
			   } else {
				  List(liveViewModel.players, id: \.id) { player in
					 NavigationLink(destination: LivePlayerDetailView(player: player)) {
						HStack {
						   if let playerImageUrl = URL(string: "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/\(player.id ?? 0).png") {
							  AsyncImage(url: playerImageUrl) { phase in
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
						   }

						   VStack(alignment: .leading) {
							  Text(player.fullName ?? "Unknown Player")
								 .font(.headline)
							  if let totalPoints = player.stats?.first(where: { $0.appliedStats?["53"] != nil })?.appliedStats?["53"] {
								 Text("Total: \(String(format: "%.2f", totalPoints))")
									.font(.subheadline)
									.foregroundColor(.gray)
							  } else {
								 Text("Total: N/A")
									.font(.subheadline)
									.foregroundColor(.gray)
							  }
						   }
						}
					 }
				  }
			   }
			}
			.navigationTitle("Live Players")
		 }
		 .onAppear {
			// Start data refresh on view appear
			startTimer()
		 }
		 .onDisappear {
			// Cancel timer when the view disappears
			stopTimer()
		 }
	  }
   }

   // Function to reload data and reset timer
   private func refreshData() {
	  stopTimer()
	  liveViewModel.loadData()
	  startTimer() // Restart timer after refresh
   }

   // Timer management
   private func startTimer() {
	  cancellable = Timer.publish(every: 20.0, on: .main, in: .common)
		 .autoconnect()
		 .sink { _ in
			liveViewModel.loadData()
		 }
   }

   private func stopTimer() {
	  cancellable?.cancel()
   }
}
