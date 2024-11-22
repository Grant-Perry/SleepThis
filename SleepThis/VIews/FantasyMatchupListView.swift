import SwiftUI
import PythonKit


struct FantasyMatchupListView: View {
   @StateObject private var fantasyViewModel: FantasyMatchupViewModel
   @StateObject private var draftViewModel: DraftViewModel
   @State private var selectedTimerInterval: Int = 0
   @AppStorage("selectedLeagueID") private var selectedLeagueID: String = AppConstants.ESPNLeagueID

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
		 // Initialize draftViewModel with the correct leagueID
		 draftViewModel.leagueID = selectedLeagueID

		 // Restore auto-refresh setting
		 if let savedInterval = UserDefaults.standard.value(forKey: "autoRefreshInterval") as? Int {
			selectedTimerInterval = savedInterval
			fantasyViewModel.setupRefreshTimer(with: savedInterval)
		 }

		 // Fetch manager details
		 draftViewModel.fetchManagerDetails(managerID: fantasyViewModel.selectedManagerID) { _ in
			// Handle completion if needed
		 }

		 // Update league name
		 fantasyViewModel.updateLeagueName()
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
			fantasyViewModel.handlePickerChange()
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
			fantasyViewModel.handlePickerChange()
		 }
	  }

	  private var leaguePickerView: some View {
		 Menu {
			Picker("League", selection: $fantasyViewModel.leagueID) {
			   Text("ESPN League").tag(AppConstants.ESPNLeagueID)
			   ForEach(fantasyViewModel.currentManagerLeagues, id: \.leagueID) { league in
				  Text(league.name).tag(league.leagueID)
			   }
			}
		 } label: {
			HStack {
			   Text(getLeagueName())
			   Image(systemName: "chevron.down")
				  .font(.caption)
			}
			.padding(8)
			.frame(maxWidth: .infinity)
			.background(Color(.secondarySystemBackground))
			.cornerRadius(8)
		 }
		 .onChange(of: fantasyViewModel.leagueID) { newValue in
			updateLeagueName()
			fantasyViewModel.handlePickerChange()
			selectedLeagueID = newValue // Persist the selected league ID
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
		 if fantasyViewModel.leagueID == AppConstants.ESPNLeagueID {
			return "ESPN League"
		 } else if let league = fantasyViewModel.sleeperLeagues.first(where: { $0.leagueID == fantasyViewModel.leagueID }) {
			return league.name
		 } else {
			return "Select League"
		 }
	  }

	  private func updateLeagueName() {
		 if fantasyViewModel.leagueID == AppConstants.ESPNLeagueID {
			fantasyViewModel.leagueName = "ESPN League"
		 } else if let league = fantasyViewModel.sleeperLeagues.first(where: { $0.leagueID == fantasyViewModel.leagueID }) {
			fantasyViewModel.leagueName = league.name
		 }
	  }
   }


