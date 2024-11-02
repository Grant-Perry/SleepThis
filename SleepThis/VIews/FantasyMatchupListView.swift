//import SwiftUI
//import Combine
//
//struct FantasyMatchupListView: View {
//   @ObservedObject var fantasyViewModel: FantasyMatchupViewModel
//
//   var body: some View {
//	  VStack(alignment: .leading) {
//		 Picker("Select Year", selection: $fantasyViewModel.selectedYear) {
//			ForEach(2015...Calendar.current.component(.year, from: Date()), id: \.self) { year in
//			   Text(String(year)).tag(year)
//			}
//		 }
//		 .pickerStyle(MenuPickerStyle())
//		 .padding()
//		 .disabled(fantasyViewModel.sleeperLeagues.isEmpty) // Disable until leagues are loaded
//		 .onChange(of: fantasyViewModel.selectedYear) { _ in
//			print("DP: Year selected - \(fantasyViewModel.selectedYear)")
//			fantasyViewModel.fetchFantasyMatchupViewModelMatchups()
//		 }
//
//		 Picker("Select Week", selection: $fantasyViewModel.selectedWeek) {
//			ForEach(1..<18) { week in
//			   Text("Week \(week)").tag(week)
//			}
//		 }
//		 .pickerStyle(MenuPickerStyle())
//		 .padding()
//		 .disabled(fantasyViewModel.sleeperLeagues.isEmpty) // Disable until leagues are loaded
//		 .onChange(of: fantasyViewModel.selectedWeek) { _ in
//			print("DP: Week selected - \(fantasyViewModel.selectedWeek)")
//			fantasyViewModel.fetchFantasyMatchupViewModelMatchups()
//		 }
//
//		 Picker("Select League", selection: $fantasyViewModel.leagueID) {
//			Text("Select League").tag("") // Placeholder option
//			ForEach(fantasyViewModel.sleeperLeagues, id: \.leagueID) { league in
//			   Text(league.name).tag(league.leagueID)
//			}
//			Text("ESPN League").tag(AppConstants.ESPNLeagueID)
//		 }
//		 .pickerStyle(MenuPickerStyle())
//		 .padding()
//		 .disabled(fantasyViewModel.sleeperLeagues.isEmpty) // Disable until leagues are loaded
//		 .onChange(of: fantasyViewModel.leagueID) { _ in
//			print("DP: League selected - \(fantasyViewModel.leagueID)")
//			fantasyViewModel.fetchFantasyMatchupViewModelMatchups()
//		 }
//
//		 if fantasyViewModel.isLoading {
//			ProgressView("Loading matchups...")
//		 } else if let errorMessage = fantasyViewModel.errorMessage {
//			Text("Error: \(errorMessage)")
//		 } else {
//			List(fantasyViewModel.matchups, id: \.teamNames) { matchup in
//			   VStack(alignment: .leading, spacing: 16) {
//				  HStack {
//					 VStack(alignment: .leading) {
//						Text(matchup.teamNames[0])
//						   .font(.headline)
//						Text("Score: \(matchup.scores[0], specifier: "%.2f")")
//						   .font(.subheadline)
//					 }
//					 Spacer()
//					 VStack(alignment: .trailing) {
//						Text(matchup.teamNames[1])
//						   .font(.headline)
//						Text("Score: \(matchup.scores[1], specifier: "%.2f")")
//						   .font(.subheadline)
//					 }
//				  }
//				  HStack {
//					 if let avatarURL = matchup.avatarURLs[0] {
//						AsyncImage(url: avatarURL) { image in
//						   image.resizable()
//							  .frame(width: 50, height: 50)
//							  .clipShape(Circle())
//						} placeholder: {
//						   ProgressView()
//						}
//					 }
//					 Text(matchup.managerNames[0])
//						.font(.caption)
//					 Spacer()
//					 if let avatarURL = matchup.avatarURLs[1] {
//						AsyncImage(url: avatarURL) { image in
//						   image.resizable()
//							  .frame(width: 50, height: 50)
//							  .clipShape(Circle())
//						} placeholder: {
//						   ProgressView()
//						}
//					 }
//					 Text(matchup.managerNames[1])
//						.font(.caption)
//				  }
//			   }
//			   .padding()
//			}
//		 }
//	  }
//	  .onAppear {
//		 print("DP: View appeared, fetching Sleeper leagues")
//		 fantasyViewModel.fetchFantasyMatchupViewModelSleeperLeagues(forUserID: AppConstants.GpSleeperID)
//	  }
//	  .padding()
//   }
//}
//
//struct SleeperLeagueResponse: Codable {
//   let leagueID: String
//   let name: String
//
//   enum CodingKeys: String, CodingKey {
//	  case leagueID = "league_id"
//	  case name
//   }
//}
//
//class FantasyMatchupViewModel: ObservableObject {
//   struct SleeperLeague: Identifiable {
//	  var id: String { leagueID }
//	  let leagueID: String
//	  let name: String
//   }
//   @Published var matchups: [any FantasyMatchup] = []
//   @Published var isLoading: Bool = false
//   @Published var errorMessage: String? = nil
//   @Published var leagueID: String = "" // Initialize with an empty string to avoid invalid tag
//   @Published var sleeperLeagues: [SleeperLeague] = []
//   @Published var selectedYear: Int = Calendar.current.component(.year, from: Date()) // Default to current year
//   @Published var selectedWeek: Int = {
//	  let firstWeek = 36 // Calendar week number for Sep 5, 2024
//	  let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
//	  let offset = currentWeek >= firstWeek ? currentWeek - firstWeek + 1 : 0
//	  return min(max(1, offset), 17)
//   }() // Default to current NFL week
//
//   private var cancellables = Set<AnyCancellable>()
//
//   func fetchFantasyMatchupViewModelMatchups() {
//	  guard !leagueID.isEmpty else {
//		 print("DP: LeagueID is empty, skipping fetchMatchups")
//		 return
//	  }
//	  isLoading = true
//	  errorMessage = nil
//	  print("DP: Fetching matchups for leagueID: \(leagueID), year: \(selectedYear), week: \(selectedWeek)")
//
//	  switch leagueID {
//		 case AppConstants.SleeperLeagueID:
//			fetchFantasyMatchupViewModelSleeperMatchups()
//		 case AppConstants.ESPNLeagueID:
//			fetchFantasyMatchupViewModelESPNMatchups()
//		 default:
//			break
//	  }
//   }
//
//   func fetchFantasyMatchupViewModelSleeperLeagues(forUserID userID: String) {
//	  print("DP: Fetching Sleeper leagues for userID: \(userID), year: \(selectedYear)")
//	  if let url = URL(string: "https://api.sleeper.app/v1/user/\(userID)/leagues/nfl/\(selectedYear)") {
//		 URLSession.shared.dataTaskPublisher(for: url)
//			.map { $0.data }
//			.decode(type: [SleeperLeagueResponse].self, decoder: JSONDecoder())
//			.receive(on: DispatchQueue.main)
//			.sink(receiveCompletion: { [weak self] completion in
//			   self?.isLoading = false
//			   switch completion {
//				  case .failure(let error):
//					 print("DP: Error fetching Sleeper leagues - \(error.localizedDescription)")
//					 self?.errorMessage = "Error fetching Sleeper leagues: \(error.localizedDescription)"
//				  case .finished:
//					 print("DP: Finished fetching Sleeper leagues")
//					 break
//			   }
//			}, receiveValue: { [weak self] leagues in
//			   self?.sleeperLeagues = leagues.map { SleeperLeague(leagueID: $0.leagueID, name: $0.name) }
//			   if let firstLeague = self?.sleeperLeagues.first {
//				  self?.leagueID = firstLeague.leagueID
//				  self?.fetchFantasyMatchupViewModelMatchups()
//			   }
//			   print("DP: Fetched Sleeper leagues: \(self?.sleeperLeagues.map { $0.name } ?? [])")
//			})
//			.store(in: &cancellables)
//	  }
//   }
//
//
//   private func fetchFantasyMatchupViewModelSleeperMatchups() {
//	  let week = selectedWeek
//	  if let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)/matchups/\(week)") {
//		 print("DP: Fetching Sleeper matchups from URL: \(url)")
//		 URLSession.shared.dataTaskPublisher(for: url)
//			.map { response -> Data in
//			   print("DP: Raw Response: \(String(data: response.data, encoding: .utf8) ?? "No Data")")
//			   return response.data
//			}
//			.decode(type: [SleeperMatchup].self, decoder: JSONDecoder())
//			.map { $0 as [any FantasyMatchup] }
//			.receive(on: DispatchQueue.main)
//			.sink(receiveCompletion: { [weak self] completion in
//			   self?.isLoading = false
//			   switch completion {
//				  case .failure(let error):
//					 print("DP: Error fetching Sleeper matchups - \(error.localizedDescription)")
//					 self?.errorMessage = "Error fetching Sleeper data: \(error.localizedDescription)"
//				  case .finished:
//					 print("DP: Finished fetching Sleeper matchups")
//					 break
//			   }
//			}, receiveValue: { [weak self] matchups in
//			   self?.matchups = matchups
//			   print("DP: Fetched Sleeper matchups: \(matchups.count) matchups")
//			})
//			.store(in: &cancellables)
//	  }
//   }
//
//   private func fetchFantasyMatchupViewModelESPNMatchups() {
//	  let year = selectedYear
//	  let week = selectedWeek
//	  if let url = URL(string: "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/\(year)/segments/0/leagues/\(leagueID)?view=mMatchupScore&view=mLiveScoring&view=mRoster&scoringPeriodId=\(week)") {
//		 print("DP: Fetching ESPN matchups from URL: \(url)")
//		 var request = URLRequest(url: url)
////		 request.addValue("application/json", forHTTPHeaderField: "Accept")
////		 request.addValue("SWID=<SWID>; espn_s2=<espn_s2>", forHTTPHeaderField: "Cookie")
//
//		 	  request.addValue("application/json", forHTTPHeaderField: "Accept")
//		 	  request.addValue("SWID=\(AppConstants.SWID); espn_s2=\(AppConstants.ESPN_S2)", forHTTPHeaderField: "Cookie")
//
//		 URLSession.shared.dataTaskPublisher(for: request)
//			.map { $0.data }
//			.tryMap { data -> Data in
//			   print("DP: Raw ESPN Response: \(String(data: data, encoding: .utf8) ?? "No Data")")
//			   return data
//			}
//			.decode(type: [ESPNFantasy.ESPNFantasyModel.Matchup].self, decoder: JSONDecoder())
//			.map { $0 as [any FantasyMatchup] }
//			.receive(on: DispatchQueue.main)
//			.sink(receiveCompletion: { [weak self] completion in
//			   self?.isLoading = false
//			   switch completion {
//				  case .failure(let error):
//					 print("DP: Error fetching ESPN matchups - \(error.localizedDescription)")
//					 self?.errorMessage = "Error fetching ESPN data: \(error.localizedDescription)"
//				  case .finished:
//					 print("DP: Finished fetching ESPN matchups")
//					 break
//			   }
//			}, receiveValue: { [weak self] matchups in
//			   self?.matchups = matchups
//			   print("DP: Fetched ESPN matchups: \(matchups.count) matchups")
//			})
//			.store(in: &cancellables)
//	  }
//   }
//}
//
//struct SleeperMatchup: Codable, FantasyMatchup {
//   var teamNames: [String]
//   var scores: [Double]
//   var avatarURLs: [URL?]
//   var managerNames: [String]
//
//   enum CodingKeys: String, CodingKey {
//	  case teamNames = "roster_id"
//	  case scores = "points"
//	  case avatarURLs = "avatar"
//	  case managerNames = "manager"
//   }
//}
