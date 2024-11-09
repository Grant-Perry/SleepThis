import SwiftUI

struct FantasyMatchupListView: View {
   @ObservedObject var fantasyViewModel: FantasyMatchupViewModel
   @State private var selectedTimerInterval: Int = 0 // Initialize with 0 for 'off'

   var body: some View {
	  NavigationView {
		 VStack(alignment: .leading) {
			HStack {
			   yearPicker
			   weekPicker
			   leaguePicker
			   refreshPicker
			}
			.padding(.horizontal)

			if fantasyViewModel.isLoading {
			   ProgressView("Loading matchups...")
			} else if let errorMessage = fantasyViewModel.errorMessage {
			   Text("Error: \(errorMessage)")
			} else {
			   matchupList
			}
		 }
		 .onAppear {
			fantasyViewModel.fetchFantasyMatchupViewModelSleeperLeagues(forUserID: AppConstants.GpSleeperID)
			fantasyViewModel.fetchFantasyMatchupViewModelMatchups()
		 }
		 .padding()
	  }
   }

   private var yearPicker: some View {
	  Picker("Year", selection: $fantasyViewModel.selectedYear) {
		 ForEach(2015...Calendar.current.component(.year, from: Date()), id: \.self) { year in
			Text(String(year)).tag(year)
		 }
	  }
	  .onChange(of: fantasyViewModel.selectedYear) { _ in
		 fantasyViewModel.fetchFantasyMatchupViewModelMatchups()
	  }
   }

   private var weekPicker: some View {
	  Picker("Week", selection: $fantasyViewModel.selectedWeek) {
		 ForEach(1..<18) { week in
			Text("Week \(week)").tag(week)
		 }
	  }
	  .onChange(of: fantasyViewModel.selectedWeek) { _ in
		 fantasyViewModel.fetchFantasyMatchupViewModelMatchups()
	  }
   }

   private var leaguePicker: some View {
	  Picker("League", selection: $fantasyViewModel.leagueID) {
		 Text("Select League").tag("")
		 ForEach(fantasyViewModel.sleeperLeagues, id: \.leagueID) { league in
			Text(league.name).tag(league.leagueID)
		 }
		 Text("ESPN League").tag(AppConstants.ESPNLeagueID)
	  }
	  .onChange(of: fantasyViewModel.leagueID) { _ in
		 fantasyViewModel.fetchFantasyMatchupViewModelMatchups()
	  }
   }

   private var refreshPicker: some View {
	  Picker("Refresh", selection: $selectedTimerInterval) {
		 ForEach([0, 10, 20, 30, 40, 50, 60], id: \.self) { interval in
			Text("\(interval == 0 ? "Off" : "\(interval) sec")").tag(interval)
		 }
	  }
	  .onChange(of: selectedTimerInterval) { _ in
		 fantasyViewModel.setupRefreshTimer(with: selectedTimerInterval)
		 fantasyViewModel.fetchFantasyMatchupViewModelMatchups() // Refresh immediately
	  }
   }

   private var matchupList: some View {
	  List(fantasyViewModel.matchups.indices, id: \.self) { index in
		 if index < fantasyViewModel.matchups.count {
			let matchup = fantasyViewModel.matchups[index]

			NavigationLink(destination: FantasyMatchupDetailView(matchup: matchup, fantasyViewModel: fantasyViewModel, selectedWeek: fantasyViewModel.selectedWeek)) {
			   matchupRow(for: matchup)
			}
			.buttonStyle(PlainButtonStyle())
		 }
	  }
   }

   private func matchupRow(for matchup: AnyFantasyMatchup) -> some View {
	  VStack(alignment: .leading, spacing: 16) {
		 HStack {
			VStack(alignment: .leading) {
			   Text(matchup.teamNames[0])
				  .font(.headline)
			   Text("Score: \(fantasyViewModel.getScore(for: matchup, teamIndex: 0), specifier: "%.2f")")
				  .font(.subheadline)
			}
			Spacer()
			VStack(alignment: .trailing) {
			   Text(matchup.teamNames[1])
				  .font(.headline)
			   Text("Score: \(fantasyViewModel.getScore(for: matchup, teamIndex: 1), specifier: "%.2f")")
				  .font(.subheadline)
			}
		 }
	  }
	  .padding()
	  .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray5)))
   }
}
