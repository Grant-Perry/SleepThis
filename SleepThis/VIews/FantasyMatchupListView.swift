import SwiftUI

struct FantasyMatchupListView: View {
   @StateObject private var fantasyViewModel: FantasyMatchupViewModel
   @State private var selectedTimerInterval: Int = 0

   init() {
	  _fantasyViewModel = StateObject(wrappedValue: FantasyMatchupViewModel())
   }

   var body: some View {
	  NavigationStack {
		 ZStack {
			Color(.systemGroupedBackground)
			   .ignoresSafeArea()

			VStack(spacing: 16) {
			   controlsSection

			   if fantasyViewModel.isLoading {
				  loadingView
			   } else if let errorMessage = fantasyViewModel.errorMessage {
				  errorView(message: errorMessage)
			   } else {
				  matchupsListView
			   }
			}
		 }
		 .navigationTitle("Fantasy Football")
	  }
	  .onAppear {
		 fantasyViewModel.fetchSleeperLeagues(forUserID: AppConstants.GpSleeperID)
		 // Restore auto-refresh setting
		 if let savedInterval = UserDefaults.standard.value(forKey: "autoRefreshInterval") as? Int {
			selectedTimerInterval = savedInterval
			fantasyViewModel.setupRefreshTimer(with: savedInterval)
		 }
	  }
   }

   // MARK: - Header Controls Section
   private var controlsSection: some View {
	  VStack(spacing: 12) {
		 HStack(spacing: 16) {
			leaguePickerView
			refreshPickerView
		 }
		 .padding(.horizontal)

		 HStack(spacing: 16) {
			yearPickerView
			weekPickerView
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
			ForEach(fantasyViewModel.sleeperLeagues, id: \.leagueID) { league in
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
	  .onChange(of: fantasyViewModel.leagueID) {
		 updateLeagueName()
		 fantasyViewModel.handlePickerChange()
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
