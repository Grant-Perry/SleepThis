import SwiftUI

struct FantasyMatchupListView: View {
   @StateObject private var playerViewModel = PlayerViewModel()
   @StateObject private var fantasyViewModel: FantasyMatchupViewModel
   @State private var selectedTimerInterval: Int = 0

   init() {
	  let playerVM = PlayerViewModel()
	  _fantasyViewModel = StateObject(wrappedValue: FantasyMatchupViewModel(playerViewModel: playerVM))
   }

   var body: some View {
	  NavigationStack {
		 VStack(alignment: .leading) {
			HStack {
			   yearPicker
			   weekPicker
			}
			HStack {
			   leaguePicker
			   refreshPicker
			}
			.padding(.horizontal)

			if fantasyViewModel.isLoading {
			   ProgressView("Loading matchups...")
			} else {
			   List(fantasyViewModel.matchups, id: \.self) { matchup in
				  NavigationLink {
					 FantasyMatchupDetailView(
						matchup: matchup,
						fantasyViewModel: fantasyViewModel,
						leagueName: fantasyViewModel.leagueName
					 )
				  } label: {
					 matchupRow(for: matchup)
				  }
			   }
			}
		 }
		 .onAppear {
			// Only fetch if we don't have data
			if fantasyViewModel.matchups.isEmpty {
			   fantasyViewModel.fetchSleeperLeagues(forUserID: AppConstants.GpSleeperID)
			}
		 }
		 .padding()
	  }
   }

   // Matchup List
   private var matchupList: some View {
	  List(fantasyViewModel.matchups, id: \.teamNames) { matchup in
		 NavigationLink(value: matchup) { // Pass the matchup as the value
			matchupRow(for: matchup)
		 }
		 .buttonStyle(PlainButtonStyle())
	  }
	  .navigationDestination(for: AnyFantasyMatchup.self) { matchup in
		 // Navigate to the detail view for the selected matchup
		 FantasyMatchupDetailView(
			matchup: matchup,
			fantasyViewModel: fantasyViewModel,
			leagueName: fantasyViewModel.leagueName
		 )
	  }
   }

   // Matchup Row
   private func matchupRow(for matchup: AnyFantasyMatchup) -> some View {
	  VStack(alignment: .leading, spacing: 16) {
		 HStack {
			VStack(alignment: .leading) {
			   Text(matchup.managerNames[0])
				  .font(.headline)
			   Text("Score: \(fantasyViewModel.getScore(for: matchup, teamIndex: 0), specifier: "%.2f")")
				  .font(.subheadline)
			}
			Spacer()
			VStack(alignment: .trailing) {
			   Text(matchup.managerNames[1])
				  .font(.headline)
			   Text("Score: \(fantasyViewModel.getScore(for: matchup, teamIndex: 1), specifier: "%.2f")")
				  .font(.subheadline)
			}
		 }
	  }
	  .padding()
	  .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray5)))
   }

   // Year Picker
   private var yearPicker: some View {
	  Picker("Year", selection: $fantasyViewModel.selectedYear) {
		 ForEach(2015...Calendar.current.component(.year, from: Date()), id: \.self) { year in
			Text(String(year)).tag(year)
		 }
	  }
	  .onChange(of: fantasyViewModel.selectedYear) {
		 fantasyViewModel.fetchFantasyMatchupViewModelMatchups()
	  }
   }

   // Week Picker
   private var weekPicker: some View {
	  Picker("Week", selection: $fantasyViewModel.selectedWeek) {
		 ForEach(1..<18) { week in
			Text("Week \(week)").tag(week)
		 }
	  }
	  .onChange(of: fantasyViewModel.selectedWeek) {
		 fantasyViewModel.fetchFantasyMatchupViewModelMatchups()
	  }
   }

   // League Picker
   private var leaguePicker: some View {
	  Picker("League", selection: $fantasyViewModel.leagueID) {
		 Text("Select League").tag("")
		 ForEach(fantasyViewModel.sleeperLeagues, id: \.leagueID) { league in
			Text(league.name).tag(league.leagueID)
		 }
		 Text("ESPN League").tag(AppConstants.ESPNLeagueID)
	  }
	  .onChange(of: fantasyViewModel.leagueID) {
		 if let selectedLeague = fantasyViewModel.sleeperLeagues.first(where: { $0.leagueID == fantasyViewModel.leagueID }) {
			fantasyViewModel.leagueName = selectedLeague.name
		 } else if fantasyViewModel.leagueID == AppConstants.ESPNLeagueID {
			fantasyViewModel.leagueName = "ESPN League"
		 }
		 fantasyViewModel.fetchFantasyMatchupViewModelMatchups()
	  }
   }

   // Refresh Picker
   private var refreshPicker: some View {
	  Picker("Refresh", selection: $fantasyViewModel.selectedTimerInterval) {
		 ForEach([0, 10, 20, 30, 40, 50, 60], id: \.self) { interval in
			Text("\(interval == 0 ? "Off" : "\(interval) sec")").tag(interval)
		 }
	  }
	  .onChange(of: fantasyViewModel.selectedTimerInterval) {
		 fantasyViewModel.setupRefreshTimer(with: fantasyViewModel.selectedTimerInterval)
	  }
   }
}
