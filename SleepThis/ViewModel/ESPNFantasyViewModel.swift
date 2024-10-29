import SwiftUI
import Combine

class ESPNFantasyViewModel: ObservableObject {
   @Published var espnFantasyModel: ESPNFantasy.ESPNFantasyModel?
   @Published var isLoading: Bool = false
   @Published var errorMessage: String? = nil

   private var leagueID = AppConstants.ESPNLeagueID
   private var cancellables = Set<AnyCancellable>()
   private var leagueYear = AppConstants.ESPNLeagueYear

   func fetchFantasyData(forWeek week: Int) {
	  guard let url = URL(string: "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/\(leagueYear)/segments/0/leagues/\(leagueID)?view=mMatchupScore&view=mLiveScoring&view=mRoster&scoringPeriodId=\(week)") else {
		 return
	  }

	  isLoading = true
	  errorMessage = nil

	  var request = URLRequest(url: url)
	  request.addValue("application/json", forHTTPHeaderField: "Accept")
	  request.addValue("SWID=\(AppConstants.SWID); espn_s2=\(AppConstants.ESPN_S2)", forHTTPHeaderField: "Cookie")

	  URLSession.shared.dataTaskPublisher(for: request)
		 .map { $0.data }
		 .decode(type: ESPNFantasy.ESPNFantasyModel.self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { [weak self] completion in
			self?.isLoading = false
			switch completion {
			   case .failure(let error):
				  self?.errorMessage = "Error fetching data: \(error)"
			   case .finished:
				  break
			}
		 }, receiveValue: { [weak self] model in
			self?.espnFantasyModel = model
		 })
		 .store(in: &cancellables)
   }

   func getTeam(for teamId: Int) -> ESPNFantasy.ESPNFantasyModel.Team? {
	  return espnFantasyModel?.teams.first(where: { $0.id == teamId })
   }
}

struct ESPNFantasyListView: View {
   @ObservedObject var espnFantasyViewModel = ESPNFantasyViewModel()
   @State private var selectedWeek = 1 // Default to week 1

   var body: some View {
	  VStack(alignment: .leading) {
		 // Pulldown picker for week selection
		 Picker("Select Week", selection: $selectedWeek) {
			ForEach(1..<17) { week in
			   Text("Week \(week)").tag(week)
			}
		 }
		 .pickerStyle(MenuPickerStyle())
		 .onChange(of: selectedWeek) { newWeek in
			espnFantasyViewModel.fetchFantasyData(forWeek: selectedWeek)
		 }
		 .padding()

		 if espnFantasyViewModel.isLoading {
			ProgressView("Loading matchups...")
		 } else if let errorMessage = espnFantasyViewModel.errorMessage {
			Text("Error: \(errorMessage)")
		 } else {
			// Display matchups in a horizontal TabView
			if let schedule = espnFantasyViewModel.espnFantasyModel?.schedule, !schedule.isEmpty {
			   TabView {
				  ForEach(schedule, id: \ .id) { matchup in
					 VStack(alignment: .leading, spacing: 16) {
						HStack {
						   if let awayTeam = espnFantasyViewModel.getTeam(for: matchup.away.teamId) {
							  VStack(alignment: .leading) {
								 Text(awayTeam.name)
									.font(.title)
									.bold()
									.frame(maxWidth: .infinity, alignment: .topLeading)
									.lineLimit(2)
									.minimumScaleFactor(0.5)
									.multilineTextAlignment(.center)
									.fixedSize(horizontal: false, vertical: true)
								 Text("\(awayTeam.roster?.entries.filter { $0.lineupSlotId < 20 || $0.lineupSlotId == 23 }.reduce(0) { $0 + ($1.playerPoolEntry.player.stats.first { $0.scoringPeriodId == selectedWeek && $0.statSourceId == 0 }?.appliedTotal ?? 0) } ?? 0, specifier: "%.2f")")
									.font(.headline)
									.foregroundColor(.gpPink)
									.frame(maxWidth: .infinity, alignment: .trailing)
							  }
						   }
						   Spacer()
						   if let homeTeam = espnFantasyViewModel.getTeam(for: matchup.home.teamId) {
							  VStack(alignment: .trailing) {
								 Text(homeTeam.name)
									.font(.title)
									.bold()
									.frame(maxWidth: .infinity, alignment: .topLeading)
									.lineLimit(2)
									.minimumScaleFactor(0.5)
									.multilineTextAlignment(.center)
									.fixedSize(horizontal: false, vertical: true)
								 Text("\(homeTeam.roster?.entries.filter { $0.lineupSlotId < 20 || $0.lineupSlotId == 23 }.reduce(0) { $0 + ($1.playerPoolEntry.player.stats.first { $0.scoringPeriodId == selectedWeek && $0.statSourceId == 0 }?.appliedTotal ?? 0) } ?? 0, specifier: "%.2f")")
									.font(.body)
									.foregroundColor(.gpPink)
									.frame(maxWidth: .infinity, alignment: .trailing)
							  }
						   }
						}
						.padding(.bottom, 16)

						ScrollView {
						   HStack(alignment: .top, spacing: 16) {
							  if let awayTeam = espnFantasyViewModel.getTeam(for: matchup.away.teamId) {
								 ESPNTeamView(team: awayTeam, week: selectedWeek)
							  }
							  if let homeTeam = espnFantasyViewModel.getTeam(for: matchup.home.teamId) {
								 ESPNTeamView(team: homeTeam, week: selectedWeek)
							  }
						   }
						}
					 }
					 .padding()
				  }
			   }
			   .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)) // Horizontal tab view
			} else {
			   Text("No matchups available for this week.")
			}
		 }
	  }
	  .padding()
	  .onAppear {
		 espnFantasyViewModel.fetchFantasyData(forWeek: selectedWeek) // Fetch data for the selected week
	  }
   }
}

struct ESPNTeamView: View {
   let team: ESPNFantasy.ESPNFantasyModel.Team
   let week: Int

   var body: some View {
	  VStack(alignment: .leading, spacing: 16) {
		 // Active Players Section
		 Text("Active Roster")
			.font(.headline)
			.padding(.bottom, 8)

		 ForEach(team.roster?.entries.filter { $0.lineupSlotId < 20 || $0.lineupSlotId == 23 }.sorted { sortOrder($0.lineupSlotId) < sortOrder($1.lineupSlotId) } ?? [], id: \ .playerPoolEntry.player.id) { playerEntry in
			VStack(spacing: 8) {
			   VStack(alignment: .trailing, spacing: 4) {
				  Text(playerEntry.playerPoolEntry.player.fullName)
					 .font(.body)
					 .bold()
					 .frame(maxWidth: .infinity, alignment: .leading)
					 .lineLimit(1)
					 .minimumScaleFactor(0.5)
			   }
			   HStack(spacing: 16) {
				  LivePlayerImageView(playerID: playerEntry.playerPoolEntry.player.id, picSize: 75)
					 .offset(x: -5, y: -10)
					 .frame(width: 75, height: 75)
				  VStack(alignment: .leading) {
					 Text(positionString(playerEntry.lineupSlotId))
						.font(.footnote)
						.frame(maxWidth: .infinity, alignment: .leading)
					 Text("\(playerEntry.playerPoolEntry.player.stats.first { $0.scoringPeriodId == week && $0.statSourceId == 0 }?.appliedTotal ?? 0, specifier: "%.2f")")
						.font(.footnote)
						.foregroundColor(.secondary)
						.frame(maxWidth: .infinity, alignment: .leading)
				  }
			   }
			}
		 }

		 Text("Active Total: \(team.roster?.entries.filter { $0.lineupSlotId < 20 || $0.lineupSlotId == 23 }.reduce(0) { $0 + ($1.playerPoolEntry.player.stats.first { $0.scoringPeriodId == week && $0.statSourceId == 0 }?.appliedTotal ?? 0) } ?? 0, specifier: "%.2f")")
			.font(.headline)
			.foregroundColor(.gpPink)
			.frame(maxWidth: .infinity, alignment: .trailing)
			.padding(.top, 8)

		 // Bench Players Section
		 Text("Bench Roster")
			.font(.headline)
			.padding(.vertical, 8)

		 ForEach(team.roster?.entries.filter { $0.lineupSlotId >= 20 && $0.lineupSlotId != 23 } ?? [], id: \ .playerPoolEntry.player.id) { playerEntry in
			VStack(spacing: 8) {
			   HStack(spacing: 16) {
				  LivePlayerImageView(playerID: playerEntry.playerPoolEntry.player.id, picSize: 75)
					 .offset(x: -5, y: -10)
					 .frame(width: 75, height: 75)
				  VStack(alignment: .leading) {
					 Text(playerEntry.playerPoolEntry.player.fullName)
						.font(.body)
						.bold()
						.frame(maxWidth: .infinity)
						.lineLimit(1)
						.minimumScaleFactor(0.5)
					 Text("\(positionString(playerEntry.lineupSlotId))")
						.font(.footnote)
						.frame(maxWidth: .infinity, alignment: .leading)
				  }
				  Spacer()
				  Text("\(playerEntry.playerPoolEntry.player.stats.first { $0.scoringPeriodId == week && $0.statSourceId == 0 }?.appliedTotal ?? 0, specifier: "%.2f")")
					 .font(.footnote)
					 .foregroundColor(.secondary)
					 .frame(maxWidth: .infinity, alignment: .trailing)
			   }
			}
		 }

		 Text("Bench Total: \(team.roster?.entries.filter { $0.lineupSlotId >= 20 && $0.lineupSlotId != 23 }.reduce(0) { $0 + ($1.playerPoolEntry.player.stats.first { $0.scoringPeriodId == week && $0.statSourceId == 0 }?.appliedTotal ?? 0) } ?? 0, specifier: "%.2f")")
			.font(.headline)
			.foregroundColor(.gpPink)
			.frame(maxWidth: .infinity, alignment: .trailing)
			.padding(.top, 8)
	  }
   }

   func sortOrder(_ lineupSlotId: Int) -> Int {
	  switch lineupSlotId {
		 case 0: return 0 // QB
		 case 2, 3: return 1 // RB
		 case 4, 5: return 2 // WR
		 case 6: return 3 // TE
		 case 16: return 4 // D/ST
		 case 17: return 5 // K
		 case 23: return 6 // FLEX
		 default: return 7 // Others
	  }
   }

   func positionString(_ lineupSlotId: Int) -> String {
	  switch lineupSlotId {
		 case 0: return "QB"
		 case 2, 3: return "RB"
		 case 4, 5: return "WR"
		 case 6: return "TE"
		 case 16: return "D/ST"
		 case 17: return "K"
		 case 23: return "FLEX"
		 default: return ""
	  }
   }
}

enum ESPNFantasy {
   struct ESPNFantasyModel: Codable {
	  let teams: [Team]
	  let schedule: [Matchup]

	  struct Team: Codable {
		 let id: Int
		 let name: String
		 let roster: Roster?

		 struct Roster: Codable {
			let entries: [PlayerEntry]
		 }

		 struct PlayerEntry: Codable {
			let playerPoolEntry: PlayerPoolEntry
			let lineupSlotId: Int

			struct PlayerPoolEntry: Codable {
			   let player: Player

			   struct Player: Codable {
				  let id: Int
				  let fullName: String
				  let stats: [Stat]

				  struct Stat: Codable {
					 let scoringPeriodId: Int
					 let statSourceId: Int
					 let appliedTotal: Double?
				  }
			   }
			}
		 }
	  }

	  struct Matchup: Codable {
		 let id: Int
		 let away: TeamMatchup
		 let home: TeamMatchup
		 let winner: String?
		 let matchupPeriodId: Int
		 let uuid: String?

		 struct TeamMatchup: Codable {
			let teamId: Int
			let roster: Roster?
		 }
	  }
   }
}
