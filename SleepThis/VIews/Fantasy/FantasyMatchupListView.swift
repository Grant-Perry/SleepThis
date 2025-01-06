import SwiftUI

struct FantasyMatchupListView: View {
   @StateObject private var fantasyViewModel = FantasyMatchupViewModel()
   @StateObject private var draftViewModel = DraftViewModel(leagueID: AppConstants.leagueID)
   @StateObject private var nflScheduleViewModel = NFLScheduleViewModel()
   @State private var selectedTimerInterval: Int = 0
   @AppStorage("selectedLeagueID") private var selectedLeagueID: String = AppConstants.ESPNLeagueID[1]

   var body: some View {
	  NavigationStack {
		 ZStack {
			Color(.systemGroupedBackground)
			   .ignoresSafeArea()

			VStack(spacing: 8) {
			   headerSection
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
		 fantasyViewModel.setupRefreshTimer(with: selectedTimerInterval)
		 fantasyViewModel.fetchFantasyMatchupViewModelMatchups()
	  }
   }

   private var headerSection: some View {
	  VStack {
		 if let avatarURL = draftViewModel.managerAvatar(for: fantasyViewModel.selectedManagerID) {
			AsyncImage(url: avatarURL) { image in
			   image.resizable().scaledToFit()
			} placeholder: {
			   Circle().fill(Color.gray.opacity(0.3))
			}
			.frame(width: 40, height: 40)
			.clipShape(Circle())
		 }
		 Text(draftViewModel.managerName(for: fantasyViewModel.selectedManagerID))
			.font(.headline)
	  }
   }

   private var controlsSection: some View {
	  VStack {
		 leaguePickerView
		 weekPickerView
	  }
   }

   private var leaguePickerView: some View {
	  Picker("League", selection: $fantasyViewModel.leagueID) {
		 ForEach(fantasyViewModel.currentManagerLeagues, id: \.id) { league in
			Text(league.name).tag(league.id)
		 }
	  }
	  .pickerStyle(MenuPickerStyle())
   }

   private var weekPickerView: some View {
	  Picker("Week", selection: $fantasyViewModel.selectedWeek) {
		 ForEach(1..<18) { week in
			Text("Week \(week)").tag(week)
		 }
	  }
	  .pickerStyle(MenuPickerStyle())
   }

   private var matchupsListView: some View {
	  ScrollView {
		 LazyVStack(spacing: 16) {
			ForEach(fantasyViewModel.matchups, id: \.self) { matchup in
			   NavigationLink(destination: FantasyMatchupDetailView(
				  matchup: matchup,
				  fantasyViewModel: fantasyViewModel,
				  nflScheduleViewModel: nflScheduleViewModel,
				  leagueName: fantasyViewModel.leagueName
			   )) {
				  FantasyMatchupCardView(
					 matchup: matchup,
					 fantasyViewModel: fantasyViewModel,
					 nflScheduleViewModel: nflScheduleViewModel
				  )
			   }
			}
		 }
		 .padding(.vertical)
	  }
   }

   private var loadingView: some View {
	  VStack {
		 Spacer()
		 ProgressView("Loading matchups...")
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
}
