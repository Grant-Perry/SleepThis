import SwiftUI

struct NFLRosterView: View {
   let team: NFLRosterModel.Team
   @StateObject var nflRosterViewModel: NFLRosterViewModel
   @State private var selectedTab: Int = 0 // Tracks which tab is selected (0 = All, 1 = Offense, 2 = Defense)

   var body: some View {
	  VStack {
		 // Tabs for sorting
		 HStack {
			Spacer()
			Button(action: { selectedTab = 1 }) {
			   Label("Offense", systemImage: "figure.run")
				  .font(.callout)
				  .padding()
				  .background(selectedTab == 1 ? Color.gpBlue : Color.clear)
				  .foregroundColor(selectedTab == 1 ? .white : .blue)
				  .cornerRadius(10)
			}
			Spacer()
			Button(action: { selectedTab = 2 }) {
			   Label("Defense", systemImage: "figure.fall")
				  .font(.callout)
				  .padding()
				  .background(selectedTab == 2 ? Color.gpBlue : Color.clear)
				  .foregroundColor(selectedTab == 2 ? .white : .blue)
				  .cornerRadius(10)
			}
			Spacer()
			Button(action: { selectedTab = 0 }) {
			   Label("All", systemImage: "figure.2")
				  .font(.callout)
				  .padding()
				  .background(selectedTab == 0 ? Color.gpBlue : Color.clear)
				  .foregroundColor(selectedTab == 0 ? .white : .blue)
				  .cornerRadius(10)
			}
			Spacer()
		 }
		 .padding(.top)

		 // List of players based on selected tab
		 List {
			if let players = nflRosterViewModel.groupedPlayersByTeam[team.displayName] {
			   ForEach(nflRosterViewModel.filteredPlayers(players: players, by: selectedTab), id: \.id) { player in
				  NavigationLink(destination: NFLPlayerDetailView(player: player)) {
					 HStack {
						// Player Image
						if let playerImageUrl = player.imageUrl {
						   AsyncImage(url: playerImageUrl) { phase in
							  switch phase {
								 case .empty:
									Image(systemName: "person.crop.circle.fill")
									   .resizable()
									   .frame(width: 50, height: 50)
								 case .success(let image):
									image
									   .resizable()
									   .frame(width: 50, height: 50)
									   .clipShape(Circle())
								 case .failure:
									Image(systemName: "person.crop.circle.fill")
									   .resizable()
									   .frame(width: 50, height: 50)
								 @unknown default:
									EmptyView()
							  }
						   }
						} else {
						   Image(systemName: "person.crop.circle.fill")
							  .resizable()
							  .frame(width: 50, height: 50)
						}

						VStack(alignment: .leading) {
						   Text(player.fullName)
							  .font(.headline)
						   Text(player.positionAbbreviation ?? "Unknown")
							  .font(.subheadline)
						}
					 }
				  }
			   }
			}
		 }
		 .listStyle(PlainListStyle())
	  }
	  .overlay(
		 HStack {
			Spacer()
			if let teamLogoURL = URL(string: team.logo ?? "") {
			   AsyncImage(url: teamLogoURL) { phase in
				  switch phase {
					 case .empty:
						Image(systemName: "photo")
						   .resizable()
						   .frame(width: 50, height: 50)
						   .opacity(0.5)
					 case .success(let image):
						image
						   .resizable()
						   .frame(width: 50, height: 50)
						   .clipShape(Circle())
					 case .failure:
						Image(systemName: "photo")
						   .resizable()
						   .frame(width: 50, height: 50)
						   .opacity(0.5)
					 @unknown default:
						EmptyView()
				  }
			   }
			   .frame(width: 50, height: 50)
			   .padding(.top, 10)
			   .padding(.trailing, 15)
			}
		 }
			.frame(maxWidth: .infinity, alignment: .topTrailing)
	  )
	  .onAppear {
		 nflRosterViewModel.fetchPlayersForAllTeams {
			// Handle any completion
		 }
	  }
   }
}
