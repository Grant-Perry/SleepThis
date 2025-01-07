import SwiftUI

struct FantasyMatchupListView: View {
   @StateObject private var fantasyViewModel: FantasyMatchupViewModel
   @StateObject private var draftViewModel: DraftViewModel
   @State private var selectedTimerInterval: Int = 0
   @AppStorage("selectedLeagueID") private var selectedLeagueID: String = AppConstants.ESPNLeagueID[1]

   private var leaguesUpdated: Bool {
	  fantasyViewModel.currentManagerLeagues.count > 0
   }

   private var currentNFLYear: Int {
	  let currentMonth = Calendar.current.component(.month, from: Date())
	  let currentYear = Calendar.current.component(.year, from: Date())
	  return currentMonth <= 2 ? currentYear - 1 : currentYear
   }

   init() {
	  let currentMonth = Calendar.current.component(.month, from: Date())
	  let currentYear = Calendar.current.component(.year, from: Date())
	  let nflYear = currentMonth <= 2 ? currentYear - 1 : currentYear

	  _fantasyViewModel = StateObject(wrappedValue: FantasyMatchupViewModel())
	  _draftViewModel = StateObject(wrappedValue: DraftViewModel(leagueID: ""))

	  fantasyViewModel.selectedYear = nflYear
   }

   var body: some View {
	  NavigationStack {
		 ZStack {
			Color(.systemGroupedBackground)
			   .ignoresSafeArea()

			VStack(spacing: 8) {
			   controlsSection

			   if fantasyViewModel.isLoading {
				  loadingView
			   } else if let errorMessage = fantasyViewModel.errorMessage {
				  errorView(message: errorMessage)
			   } else {
				  FantasyMatchupsListView(fantasyViewModel: fantasyViewModel)
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
		 fantasyViewModel.setupRefreshTimer(with: 0)
		 selectedTimerInterval = 0
		 // set the userID for each league
		 fantasyViewModel.fetchESPNManagerLeagues(forUserID: AppConstants.GpESPNID)
		 Task {
			await fantasyViewModel.fetchSleeperLeagues(forUserID: AppConstants.GpSleeperID)
		 }

		 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			fantasyViewModel.currentManagerLeagues = Array(Set(fantasyViewModel.currentManagerLeagues))
			fantasyViewModel.objectWillChange.send()
			fantasyViewModel.debugPrintLeagues()
		 }
	  }
   }

   @State private var showControls = false

   var controlsSection: some View {
	  VStack {
		 // Toggle button to expand/collapse the dropdown
		 Button(action: {
			withAnimation {
			   showControls.toggle()
			}
		 }) {
			HStack {
			   Text(showControls ? "Hide Filters" : "Show Filters")
				  .font(.headline)
				  .foregroundColor(.white)
			   Image(systemName: showControls ? "chevron.up" : "chevron.down")
				  .foregroundColor(.white)
			}
			.padding()
		 }

		 // Conditionally show pickers if showControls is true
		 if showControls {
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
			   .padding(.bottom, 8) // some extra padding at bottom
			}
			.transition(.slide) // animate appearance
		 }
	  }
	  .padding(.top)
	  .cornerRadius(10)
	  .padding(.horizontal)
   }

   private var yearPickerView: some View {
	  Menu {
		 Picker("Year", selection: $fantasyViewModel.selectedYear) {
			ForEach(2020...currentNFLYear, id: \.self) { year in
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
		 if let selectedLeague = fantasyViewModel.currentManagerLeagues.first(where: { $0.id == fantasyViewModel.leagueID }) {
			switch selectedLeague.type {
			   case .espn:
				  fantasyViewModel.fetchFantasyData(forWeek: fantasyViewModel.selectedWeek)
			   case .sleeper:
				  fantasyViewModel.fetchSleeperMatchups()
			}
		 }
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
	  .onChange(of: fantasyViewModel.selectedWeek) { newValue in
		 fantasyViewModel.matchups = []
		 fantasyViewModel.errorMessage = nil
		 fantasyViewModel.currentManagerLeagues = fantasyViewModel.originalManagerLeagues
		 if let selectedLeague = fantasyViewModel.currentManagerLeagues.first(where: { $0.id == fantasyViewModel.leagueID }) {
			fantasyViewModel.leagueName = selectedLeague.name
			fantasyViewModel.isLoading = true
			DispatchQueue.main.async {
			   switch selectedLeague.type {
				  case .espn:
					 print("Fetching ESPN matchups for week \(newValue)")
					 fantasyViewModel.matchups = []
					 fantasyViewModel.fetchFantasyData(forWeek: newValue)
				  case .sleeper:
					 print("Fetching Sleeper matchups for week \(newValue)")
					 fantasyViewModel.matchups = []
					 fantasyViewModel.fetchSleeperMatchups()
			   }
			}
		 } else {
			if let firstLeague = fantasyViewModel.currentManagerLeagues.first {
			   fantasyViewModel.leagueID = firstLeague.id
			   fantasyViewModel.leagueName = firstLeague.name
			   fantasyViewModel.isLoading = true
			   DispatchQueue.main.async {
				  switch firstLeague.type {
					 case .espn:
						fantasyViewModel.matchups = []
						fantasyViewModel.fetchFantasyData(forWeek: newValue)
					 case .sleeper:
						fantasyViewModel.matchups = []
						fantasyViewModel.fetchSleeperMatchups()
				  }
			   }
			}
		 }
	  }
   }

   private var leaguePickerView: some View {
	  Menu {
		 Picker("League", selection: $fantasyViewModel.leagueID) {
			ForEach(fantasyViewModel.currentManagerLeagues, id: \.id) { league in
			   HStack {
				  Image(league.type == .espn ? "espn_logo" : "sleeper_logo")
					 .resizable()
					 .scaledToFit()
					 .frame(width: 10, height: 10)
				  Text(league.name).tag(league.id)
			   }
			}
		 }
	  } label: {
		 HStack {
			if let selectedLeague = fantasyViewModel.currentManagerLeagues.first(where: { $0.id == fantasyViewModel.leagueID }) {
			   Image(selectedLeague.type == .espn ? "espn_logo" : "sleeper_logo")
				  .resizable()
				  .scaledToFit()
				  .frame(width: 10, height: 10)
			}
			Text(fantasyViewModel.leagueName.isEmpty ? "Select League" : fantasyViewModel.leagueName)
			Image(systemName: "chevron.down")
			   .font(.caption)
		 }
		 .padding(8)
		 .frame(maxWidth: .infinity)
		 .background(Color(.secondarySystemBackground))
		 .cornerRadius(8)
	  }
	  .onChange(of: fantasyViewModel.leagueID) {
		 fantasyViewModel.handlePickerChange(newLeagueID: fantasyViewModel.leagueID)
		 if let selectedLeague = fantasyViewModel.currentManagerLeagues.first(where: { $0.id == fantasyViewModel.leagueID }) {
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
			ForEach([0, 20, 45, 60, 90, 120], id: \.self) { interval in
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
		 Text(message)
			.font(.system(size: 18, weight: .semibold))
			.foregroundColor(.gpOrange)
			.multilineTextAlignment(.center)
			.padding(.horizontal, 20)
		 Spacer()
	  }
   }
}
