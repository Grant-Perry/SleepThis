//import SwiftUI
//import Combine
//
//class ESPNFantasyViewModel: ObservableObject {
//   @Published var espnFantasyModel: ESPNFantasy.ESPNFantasyModel?
//   @Published var isLoading: Bool = false
//   @Published var errorMessage: String? = nil
//   @Published var leagueYear = AppConstants.ESPNLeagueYear
//
//   private var leagueID = AppConstants.ESPNLeagueID
//   private var cancellables = Set<AnyCancellable>()
//
//   func fetchFantasyData(forWeek week: Int) {
//	  guard let url = URL(string: "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/\(leagueYear)/segments/0/leagues/\(leagueID)?view=mMatchupScore&view=mLiveScoring&view=mRoster&scoringPeriodId=\(week)") else {
//		 return
//	  }
//
//	  isLoading = true
//	  errorMessage = nil
//
//	  var request = URLRequest(url: url)
//	  request.addValue("application/json", forHTTPHeaderField: "Accept")
//	  request.addValue("SWID=\(AppConstants.SWID); espn_s2=\(AppConstants.ESPN_S2)", forHTTPHeaderField: "Cookie")
//
//	  URLSession.shared.dataTaskPublisher(for: request)
//		 .map { $0.data }
//		 .decode(type: ESPNFantasy.ESPNFantasyModel.self, decoder: JSONDecoder())
//		 .receive(on: DispatchQueue.main)
//		 .sink(receiveCompletion: { [weak self] completion in
//			self?.isLoading = false
//			switch completion {
//			   case .failure(let error):
//				  self?.errorMessage = "Error fetching data: \(error)"
//			   case .finished:
//				  break
//			}
//		 }, receiveValue: { [weak self] model in
//			self?.espnFantasyModel = model
//		 })
//		 .store(in: &cancellables)
//   }
//
//   func getTeam(for teamId: Int) -> ESPNFantasy.ESPNFantasyModel.Team? {
//	  return espnFantasyModel?.teams.first(where: { $0.id == teamId })
//   }
//
//   func getMatchup(for week: Int, teamId: Int) -> ESPNFantasy.ESPNFantasyModel.Matchup? {
//	  return espnFantasyModel?.schedule.first(where: { $0.matchupPeriodId == week && ($0.away.teamId == teamId || $0.home.teamId == teamId) })
//   }
//}
//
//struct ESPNFantasyListView: View {
//   @ObservedObject var espnFantasyViewModel = ESPNFantasyViewModel()
//   @State private var selectedWeek: Int = {
//	  let firstWeek = 36 // Calendar week number for Sep 5, 2024
//	  let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
//	  let offset = currentWeek >= firstWeek ? currentWeek - firstWeek + 1 : 0
//	  return min(max(1, offset), 17)
//   }() // Default to current NFL week
//
//   @State private var selectedLeagueYear: Int = Calendar.current.component(.year, from: Date())
//
//   var body: some View {
//	  VStack(alignment: .leading) {
//		 // Pulldown picker for league year and week selection
//		 HStack {
//			Picker("Select Year", selection: $selectedLeagueYear) {
//			   ForEach(2015...Calendar.current.component(.year, from: Date()), id: \.self) { year in
//				  Text(String(format: "%d", year)).tag(year)
//			   }
//
//			}
//			.pickerStyle(MenuPickerStyle())
//			.onChange(of: selectedLeagueYear) {
//			   espnFantasyViewModel.leagueYear = "\(selectedLeagueYear)"
//			   espnFantasyViewModel.fetchFantasyData(forWeek: selectedWeek)
//			}
//
//			Picker("Select Week", selection: $selectedWeek) {
//			   ForEach(1..<17) { week in
//				  Text("Week \(week)").tag(week)
//			   }
//			}
//			.pickerStyle(MenuPickerStyle())
//			.onChange(of: selectedWeek) {
//			   espnFantasyViewModel.fetchFantasyData(forWeek: selectedWeek)
//			}
//		 }
//		 .padding()
//
//		 if espnFantasyViewModel.isLoading {
//			ProgressView("Loading matchups...")
//		 } else if let errorMessage = espnFantasyViewModel.errorMessage {
//			Text("Error: \(errorMessage)")
//		 } else {
//			// Display matchups in a horizontal TabView
//			if let schedule = espnFantasyViewModel.espnFantasyModel?.schedule, !schedule.isEmpty {
//			   TabView {
//				  ForEach(schedule.filter { $0.matchupPeriodId == selectedWeek }, id: \ .id) { matchup in
//					 VStack(alignment: .leading, spacing: 16) {
//						// MARK: Team names and scores
//						HStack {
//						   if let awayTeam = espnFantasyViewModel.getTeam(for: matchup.away.teamId),
//							  let homeTeam = espnFantasyViewModel.getTeam(for: matchup.home.teamId) {
//
//							  let awayTeamScore = awayTeam.roster?.entries.filter { $0.lineupSlotId < 20 || $0.lineupSlotId == 23 }.reduce(0) { $0 + ($1.playerPoolEntry.player.stats.first { $0.scoringPeriodId == selectedWeek && $0.statSourceId == 0 }?.appliedTotal ?? 0) } ?? 0
//
//							  let homeTeamScore = homeTeam.roster?.entries.filter { $0.lineupSlotId < 20 || $0.lineupSlotId == 23 }.reduce(0) { $0 + ($1.playerPoolEntry.player.stats.first { $0.scoringPeriodId == selectedWeek && $0.statSourceId == 0 }?.appliedTotal ?? 0) } ?? 0
//
//							  VStack(alignment: .leading) {
//								 Text(awayTeam.name)
//									.font(.system(size: 25, weight: .bold))
//								 Text("\(awayTeamScore, specifier: "%.2f")")
//									.font(.system(size: 20, weight: .bold))
//							  }
//							  .foregroundColor(awayTeamScore != homeTeamScore ? awayTeamScore > homeTeamScore ? .gpGreen : .gpRedPink : .gpWhite)
//
//							  Spacer()
//
//							  VStack(alignment: .trailing) {
//								 Text(homeTeam.name)
//									.font(.system(size: 25, weight: .bold))
//								 Text("\(homeTeamScore, specifier: "%.2f")")
//									.font(.system(size: 20, weight: .bold))
//							  }
//							  .foregroundColor(awayTeamScore != homeTeamScore ? homeTeamScore > awayTeamScore ? .gpGreen : .gpRedPink : .gpWhite)
//						   }
//						}
//						.padding()
//
//						ScrollView {
//						   // Active roster section
//						   HStack {
//							  Text("Active Roster")
//								 .font(.headline)
//								 .foregroundColor(.primary)
//								 .padding()
//								 .frame(maxWidth: .infinity, alignment: .leading)
//								 .frame(height: 30)
//								 .background(LinearGradient(gradient: Gradient(colors: [.gpMinty, .clear]),
//															startPoint: .top, endPoint: .bottom).opacity(0.5))
//								 .opacity(0.7)
//						   }
//
//						   HStack(alignment: .top, spacing: 16) {
//							  if let awayTeam = espnFantasyViewModel.getTeam(for: matchup.away.teamId) {
//								 ESPNTeamView(team: awayTeam, week: selectedWeek)
//							  }
//							  if let homeTeam = espnFantasyViewModel.getTeam(for: matchup.home.teamId) {
//								 ESPNTeamView(team: homeTeam, week: selectedWeek)
//							  }
//						   }
//
//						   // Bench roster section
//
//						   // Active roster section
//						   HStack {
//							  Text("Bench Roster")
//								 .font(.headline)
//								 .foregroundColor(.primary)
//								 .padding()
//								 .frame(maxWidth: .infinity, alignment: .leading)
//								 .frame(height: 30)
//								 .background(LinearGradient(gradient: Gradient(colors: [.gpRedLight, .clear]), startPoint: .top, endPoint: .bottom))
//								 .opacity(0.7)
//						   }
//
//						   HStack(alignment: .top, spacing: 16) {
//							  if let awayTeam = espnFantasyViewModel.getTeam(for: matchup.away.teamId) {
//								 ESPNBenchView(team: awayTeam, week: selectedWeek)
//							  }
//							  if let homeTeam = espnFantasyViewModel.getTeam(for: matchup.home.teamId) {
//								 ESPNBenchView(team: homeTeam, week: selectedWeek)
//							  }
//						   }
//						}
//					 }
//					 .padding()
//					 .background(Color(UIColor.systemBackground))
//					 .cornerRadius(12)
//					 .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
//				  }
//			   }
//			   .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)) // Horizontal tab view
//			} else {
//			   Text("No matchups available for this week.")
//				  .font(.headline)
//				  .foregroundColor(.secondary)
//				  .frame(maxWidth: .infinity, alignment: .center)
//			}
//		 }
//	  }
//	  .padding()
//	  .background(Color(UIColor.secondarySystemBackground))
//	  .cornerRadius(16)
//	  .shadow(radius: 5)
//	  .onAppear {
//		 espnFantasyViewModel.fetchFantasyData(forWeek: selectedWeek) // Fetch data for the selected week
//	  }
//   }
//}
//
//struct ESPNTeamView: View {
//   let team: ESPNFantasy.ESPNFantasyModel.Team
//   let week: Int
//
//   var body: some View {
//	  VStack(alignment: .leading, spacing: 16) {
//		 ForEach(team.roster?.entries.filter { $0.lineupSlotId < 20 || $0.lineupSlotId == 23 }.sorted { sortOrder($0.lineupSlotId) < sortOrder($1.lineupSlotId) } ?? [], id: \ .playerPoolEntry.player.id) { playerEntry in
//
//			ESPNFantasyPlayerView(playerEntry: playerEntry, week: week)
//			   .padding(.vertical, 4)
//			   .background(LinearGradient(gradient: Gradient(colors: [.gpDark1, .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
//			   .cornerRadius(10)
//		 }
//
//		 Text("\(team.roster?.entries.filter { $0.lineupSlotId < 20 || $0.lineupSlotId == 23 }.reduce(0) { $0 + ($1.playerPoolEntry.player.stats.first { $0.scoringPeriodId == week && $0.statSourceId == 0 }?.appliedTotal ?? 0) } ?? 0, specifier: "%.2f")")
//			.font(.system(size: 20, weight: .medium))
//			.foregroundColor(.gpGreen)
//			.frame(maxWidth: .infinity, alignment: .trailing)
//			.padding(.top, 8)
//	  }
//   }
//
//   func sortOrder(_ lineupSlotId: Int) -> Int {
//	  switch lineupSlotId {
//		 case 0: return 0 // QB
//		 case 2, 3: return 1 // RB
//		 case 4, 5: return 2 // WR
//		 case 6: return 3 // TE
//		 case 23: return 4 // FLEX
//		 case 16: return 5 // D/ST
//		 case 17: return 6 // K
//		 default: return 7 // Others
//	  }
//   }
//}
//
//struct ESPNBenchView: View {
//   let team: ESPNFantasy.ESPNFantasyModel.Team
//   let week: Int
//
//   var body: some View {
//	  VStack(alignment: .leading, spacing: 16) {
//		 ForEach(team.roster?.entries.filter { $0.lineupSlotId >= 20 && $0.lineupSlotId != 23 }.sorted { sortOrder($0.lineupSlotId) < sortOrder($1.lineupSlotId) } ?? [], id: \ .playerPoolEntry.player.id) { playerEntry in
//
//			ESPNFantasyPlayerView(playerEntry: playerEntry, week: week)
//			   .padding(.vertical, 4)
//			   .background(LinearGradient(gradient: Gradient(colors: [.gpDark1, .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
//			   .cornerRadius(10)
//			   .opacity(0.75) // Set bench players to 75% opacity
//		 }
//
//		 Text("\(team.roster?.entries.filter { $0.lineupSlotId >= 20 && $0.lineupSlotId != 23 }.reduce(0) { $0 + ($1.playerPoolEntry.player.stats.first { $0.scoringPeriodId == week && $0.statSourceId == 0 }?.appliedTotal ?? 0) } ?? 0, specifier: "%.2f")")
//			.font(.system(size: 20, weight: .medium))
//			.foregroundColor(.gpGreen)
//			.frame(maxWidth: .infinity, alignment: .trailing)
//			.padding(.top, 8)
//	  }
//   }
//
//   func sortOrder(_ lineupSlotId: Int) -> Int {
//	  switch lineupSlotId {
//		 case 0: return 0 // QB
//		 case 2, 3: return 1 // RB
//		 case 4, 5: return 2 // WR
//		 case 6: return 3 // TE
//		 case 23: return 4 // FLEX
//		 case 16: return 5 // D/ST
//		 case 17: return 6 // K
//		 default: return 7 // Others
//	  }
//   }
//}
//
//struct ESPNFantasyPlayerView: View {
//   let playerEntry: ESPNFantasy.ESPNFantasyModel.Team.PlayerEntry
//   let week: Int
//   @State private var lastScore: Double? = nil
//
//   var body: some View {
//	  VStack(spacing: 8) {
//		 VStack(alignment: .leading, spacing: 4) {
//			Text(playerEntry.playerPoolEntry.player.fullName)
//			   .font(.body)
//			   .bold()
//			   .frame(maxWidth: .infinity, alignment: .leading)
//			   .lineLimit(1)
//			   .minimumScaleFactor(0.5)
//		 }
//		 .background(LinearGradient(gradient: Gradient(colors: [.gpDeltaPurple.opacity(0.2), .clear]), startPoint: .top, endPoint: .bottom))
//
//		 HStack(spacing: 5) {
//			// MARK: Player Thumbnail
//			LivePlayerImageView(playerID: playerEntry.playerPoolEntry.player.id, picSize: 65)
//			//               .offset(x: -1, y: -20)
//			   .frame(width: 65, height: 65)
//
//			VStack(alignment: .leading, spacing: 2) {
//			   let currentScore = playerEntry.playerPoolEntry.player.stats.first { $0.scoringPeriodId == week && $0.statSourceId == 0 }?.appliedTotal ?? 0
//			   // MARK: Position
//			   Text(positionString(playerEntry.lineupSlotId))
//				  .font(.system(size: 10, weight: .light))
//				  .foregroundColor(.primary)
//				  .frame(maxWidth: .infinity, alignment: .leading)
//				  .padding(.top, 5)
//
//			   // MARK: Score
//			   Text("\(currentScore, specifier: "%.2f")")
//				  .font(.system(size: 30, weight: .medium))
//				  .foregroundColor(.secondary)
//				  .frame(maxWidth: .infinity)
//				  .lineLimit(1)
//				  .minimumScaleFactor(0.5)
//				  .scaledToFit()
//				  .edgesIgnoringSafeArea(.all)
//				  .padding(.trailing)
//				  .offset(x: 8)
//
//			   // MARK: Last Play amount
//			   Text("+/- \(currentScore - (lastScore ?? currentScore), specifier: "%.2f")")
//				  .font(.system(size: 12, weight: .light))
//				  .foregroundColor(currentScore - (lastScore ?? 0) > 0 ? .gpGreen : .gpRedPink)
//				  .offset(x: 8)
//			}
//		 }
//		 .frame(height: 60) // Reduced height to be 5px larger than the thumbnail image
//							//         .padding(.horizontal, 4)
//		 .padding(.vertical, 2)
//		 .background(LinearGradient(gradient: Gradient(colors: [.gpDark1, .clear]), startPoint: .top, endPoint: .bottom))
//		 .cornerRadius(8)
//		 .onAppear {
//			lastScore = playerEntry.playerPoolEntry.player.stats.first { $0.scoringPeriodId == week && $0.statSourceId == 0 }?.appliedTotal
//		 }
//	  }
//   }
//
//   func positionString(_ lineupSlotId: Int) -> String {
//	  switch lineupSlotId {
//		 case 0: return "QB"
//		 case 2, 3: return "RB"
//		 case 4, 5: return "WR"
//		 case 6: return "TE"
//		 case 16: return "D/ST"
//		 case 17: return "K"
//		 case 23: return "FLEX"
//		 default: return ""
//	  }
//   }
//}
//
//enum ESPNFantasy {
//   struct ESPNFantasyModel: Codable {
//	  let teams: [Team]
//	  let schedule: [Matchup]
//
//	  struct Team: Codable {
//		 let id: Int
//		 let name: String
//		 let roster: Roster?
//
//		 struct Roster: Codable {
//			let entries: [PlayerEntry]
//		 }
//
//		 struct PlayerEntry: Codable {
//			let playerPoolEntry: PlayerPoolEntry
//			let lineupSlotId: Int
//
//			struct PlayerPoolEntry: Codable {
//			   let player: Player
//
//			   struct Player: Codable {
//				  let id: Int
//				  let fullName: String
//				  let stats: [Stat]
//
//				  struct Stat: Codable {
//					 let scoringPeriodId: Int
//					 let statSourceId: Int
//					 let appliedTotal: Double?
//				  }
//			   }
//			}
//		 }
//	  }
//
//	  struct Matchup: Codable {
//		 let id: Int
//		 let away: TeamMatchup
//		 let home: TeamMatchup
//		 let winner: String?
//		 let matchupPeriodId: Int
//		 let uuid: String?
//
//		 struct TeamMatchup: Codable {
//			let teamId: Int
//			let roster: Roster?
//		 }
//	  }
//   }
//}
