import SwiftUI

struct FantasyMatchupListView: View {
   @StateObject private var fantasyViewModel: FantasyMatchupViewModel
   @StateObject private var draftViewModel: DraftViewModel
   @State private var selectedTimerInterval: Int = 0
   @AppStorage("selectedLeagueID") private var selectedLeagueID: String = AppConstants.ESPNLeagueID[1]

   private var leaguesUpdated: Bool {
	  fantasyViewModel.currentManagerLeagues.count > 0
   }

   init() {
	  // Initialize fantasyViewModel
	  _fantasyViewModel = StateObject(wrappedValue: FantasyMatchupViewModel())
	  // Initialize draftViewModel with a placeholder value
	  _draftViewModel = StateObject(wrappedValue: DraftViewModel(leagueID: ""))
   }

   var body: some View {
	  NavigationStack {
		 ZStack {
			Color(.systemGroupedBackground)
			   .ignoresSafeArea()

			VStack(spacing: 8) { // Reduce spacing here
			   HStack {
				  AsyncImage(url: draftViewModel.managerAvatar(for: fantasyViewModel.selectedManagerID)) { image in
					 image
						.resizable()
						.scaledToFit()
						.frame(width: 40, height: 40)
						.clipShape(Circle())
				  } placeholder: {
					 Circle()
						.fill(Color.gray.opacity(0.3))
						.frame(width: 40, height: 40)
				  }

				  Text(draftViewModel.managerName(for: fantasyViewModel.selectedManagerID))
					 .font(.system(size: 18))
					 .foregroundColor(.gpGray)
			   }
			   .padding(.top, 2)
			   .padding(.bottom, 4) // Add bottom padding

			   controlsSection // add the pickers

			   if fantasyViewModel.isLoading {
				  loadingView
			   } else if let errorMessage = fantasyViewModel.errorMessage {
				  errorView(message: errorMessage)
			   } else {
				  matchupsListView
			   }
			}
		 }
		 .toolbar {
			ToolbarItem(placement: .principal) {
			   Text(fantasyViewModel.leagueName)
				  .font(.system(size: 26))
				  .frame(maxWidth: .infinity)
				  .lineLimit(1)
				  .minimumScaleFactor(0.5)
				  .scaledToFit()
			}
		 }
	  }

	  .onAppear {
		 // reset the timer 
		 fantasyViewModel.setupRefreshTimer(with: 0)
		 selectedTimerInterval = 0
		 // Fetch ESPN and Sleeper leagues
		 fantasyViewModel.fetchESPNManagerLeagues(forUserID: AppConstants.GpESPNID)
		 // Use Task to call the async function
		 Task {
			await fantasyViewModel.fetchSleeperLeagues(forUserID: AppConstants.GpSleeperID)
		 }

		 // Deduplicate after fetching
		 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			fantasyViewModel.currentManagerLeagues = Array(Set(fantasyViewModel.currentManagerLeagues))
			fantasyViewModel.objectWillChange.send()

			// Debug print leagues
			fantasyViewModel.debugPrintLeagues()
		 }
	  }

   }

   // MARK: - Header Controls Section
   var controlsSection: some View {
	  VStack(spacing: 12) {
		 HStack(spacing: 16) {
			leaguePickerView
			weekPickerView
		 }
		 .padding(.horizontal)

		 HStack(spacing: 16) {
			yearPickerView
			refreshPickerView
		 }
		 .padding(.horizontal)
	  }
	  .padding(.top)
   }

   private var yearPickerView: some View {
	  Menu {
		 Picker("Year", selection: $fantasyViewModel.selectedYear) {
			ForEach(2015...Calendar.current.component(.year, from: Date()), id: \.self) { year in
			   Text(String(format: "%d", year)).tag(year)
			}
		 }
	  } label: {
		 HStack {
			Text("Year: \(String(format: "%d", fantasyViewModel.selectedYear))")
			Image(systemName: "chevron.down")
			   .font(.caption)
		 }
		 .padding(8)
		 .frame(maxWidth: .infinity)
		 .background(Color(.secondarySystemBackground))
		 .cornerRadius(8)
	  }
	  .onChange(of: fantasyViewModel.selectedYear) {
		 fantasyViewModel.handlePickerChange(newLeagueID: fantasyViewModel.leagueID)
	  }
   }

   private var weekPickerView: some View {
	  Menu {
		 Picker("Week", selection: $fantasyViewModel.selectedWeek) {
			ForEach(1..<18) { week in
			   Text("Week \(week)").tag(week)
			}
		 }
	  } label: {
		 HStack {
			Text("Week \(fantasyViewModel.selectedWeek)")
			Image(systemName: "chevron.down")
			   .font(.caption)
		 }
		 .padding(8)
		 .frame(maxWidth: .infinity)
		 .background(Color(.secondarySystemBackground))
		 .cornerRadius(8)
	  }
	  .onChange(of: fantasyViewModel.selectedWeek) {
		 fantasyViewModel.handlePickerChange(newLeagueID: fantasyViewModel.leagueID)
	  }
   }

   private var leaguePickerView: some View {
	  Menu {
		 Picker("League", selection: $fantasyViewModel.leagueID) {
			ForEach(fantasyViewModel.currentManagerLeagues, id: \.id) { league in
			   Text(league.name).tag(league.id)
			}
		 }
	  } label: {
		 HStack {
			Text(fantasyViewModel.leagueName.isEmpty ? "Select League" : fantasyViewModel.leagueName)
			Image(systemName: "chevron.down")
			   .font(.caption)
		 }
		 .padding(8)
		 .frame(maxWidth: .infinity)
		 .background(Color(.secondarySystemBackground))
		 .cornerRadius(8)
	  }
	  .onChange(of: fantasyViewModel.leagueID) { newValue in
		 // Update this section
		 fantasyViewModel.handlePickerChange(newLeagueID: newValue)
		 if let selectedLeague = fantasyViewModel.currentManagerLeagues.first(where: { $0.id == newValue }) {
			fantasyViewModel.leagueName = selectedLeague.name
			switch selectedLeague.type {
			   case .espn:
				  print("Fetching ESPN matchups for league: \(selectedLeague.name)")
				  fantasyViewModel.fetchFantasyData(forWeek: fantasyViewModel.selectedWeek)
			   case .sleeper:
				  print("Fetching Sleeper matchups for league: \(selectedLeague.name)")
				  fantasyViewModel.fetchSleeperMatchups()
			}
		 } else {
			print("Error: Selected league not found in currentManagerLeagues.")
		 }
	  }
   }


   private var refreshPickerView: some View {
	  Menu {
		 Picker("Refresh", selection: $selectedTimerInterval) {
			ForEach([0, 10, 20, 30, 40, 50, 60], id: \.self) { interval in
			   Text("\(interval == 0 ? "Off" : "\(interval) sec")").tag(interval)
			}
		 }
	  } label: {
		 HStack {
			Text(selectedTimerInterval == 0 ? "Auto Refresh: Off" : "Refresh: \(selectedTimerInterval)s")
			Image(systemName: "chevron.down")
			   .font(.caption)
		 }
		 .padding(8)
		 .frame(maxWidth: .infinity)
		 .background(Color(.secondarySystemBackground))
		 .cornerRadius(8)
	  }
	  .onChange(of: selectedTimerInterval) {
		 UserDefaults.standard.set(selectedTimerInterval, forKey: "autoRefreshInterval")
		 fantasyViewModel.setupRefreshTimer(with: selectedTimerInterval)
		 fantasyViewModel.fetchFantasyMatchupViewModelMatchups()
	  }
   }

   // MARK: - Loading & Error Views
   private var loadingView: some View {
	  VStack {
		 Spacer()
		 ProgressView("Loading matchups...")
			.progressViewStyle(CircularProgressViewStyle())
		 Spacer()
	  }
   }

   private func errorView(message: String) -> some View {
	  VStack {
		 Spacer()
		 Text("Error: \(message)")
			.foregroundColor(.red)
		 Spacer()
	  }
   }

   // MARK: - Matchups List
   private var matchupsListView: some View {
	  ScrollView {
		 LazyVStack(spacing: 16) {
			ForEach(fantasyViewModel.matchups, id: \.self) { matchup in
			   NavigationLink(value: matchup) {
				  FantasyMatchupCardView(
					 matchup: matchup,
					 fantasyViewModel: fantasyViewModel
				  )
				  // Add tap gestures for avatars
				  .overlay(
					 HStack {
						avatarOverlay(for: matchup.awayTeamID.description)
						Spacer()
						avatarOverlay(for: matchup.homeTeamID.description)
					 }
				  )
			   }
			   .contextMenu {
				  Button("View \(matchup.managerNames[0])'s Leagues") {
					 fantasyViewModel.updateSelectedManager(matchup.awayTeamID.description)
				  }
				  Button("View \(matchup.managerNames[1])'s Leagues") {
					 fantasyViewModel.updateSelectedManager(matchup.homeTeamID.description)
				  }
			   }
			}
		 }
		 .padding(.vertical)
	  }
	  .navigationDestination(for: AnyFantasyMatchup.self) { matchup in
		 FantasyMatchupDetailView(
			matchup: matchup,
			fantasyViewModel: fantasyViewModel,
			leagueName: fantasyViewModel.leagueName
		 )
	  }
   }


   // MARK: - Helper Functions

   private func avatarOverlay(for managerID: String) -> some View {
	  Circle()
		 .fill(Color.clear)
		 .frame(width: 40, height: 40)
		 .onTapGesture {
			fantasyViewModel.updateSelectedManager(managerID)
		 }
   }

   private func getLeagueName() -> String {
	  // Add this debug print
	  print("DP - getLeagueName: currentManagerLeagues count: \(fantasyViewModel.currentManagerLeagues.count)")
	  if let league = fantasyViewModel.currentManagerLeagues.first(where: { $0.id == fantasyViewModel.leagueID }) {
		 return league.name
	  } else {
		 return "Select League"
	  }
   }

   private func updateLeagueName() {
	  // Add this debug print
	  print("DP - updateLeagueName: currentManagerLeagues count: \(fantasyViewModel.currentManagerLeagues.count)")
	  if let league = fantasyViewModel.currentManagerLeagues.first(where: { $0.id == fantasyViewModel.leagueID }) {
		 fantasyViewModel.leagueName = league.name
		 // Add this debug print
		 print("DP - updateLeagueName: League name updated to \(league.name)")
	  } else {
		 // Add this debug print
		 print("DP - updateLeagueName: No matching league found for ID \(fantasyViewModel.leagueID)")
	  }
   }

}
