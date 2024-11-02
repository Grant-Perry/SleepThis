import SwiftUI
import Combine

protocol FantasyMatchup {
   var teamNames: [String] { get }
   var scores: [Double] { get }
   var avatarURLs: [URL?] { get }
   var managerNames: [String] { get }
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

	  struct Matchup: Codable, FantasyMatchup { // Explicitly conforms to FantasyMatchup
		 let away: Team
		 let home: Team
		 let matchupPeriodId: Int
		 let winner: String?
		 let awayTotalPoints: Double
		 let homeTotalPoints: Double

		 // Implement required properties for FantasyMatchup
		 var teamNames: [String] {
			return [away.name, home.name]
		 }

		 var scores: [Double] {
			return [awayTotalPoints, homeTotalPoints]
		 }

		 var avatarURLs: [URL?] {
			return [nil, nil] // Modify if URLs are available
		 }

		 var managerNames: [String] {
			return [away.name, home.name]
		 }
	  }
   }
}


struct AnyFantasyMatchup: FantasyMatchup {
   private let _teamNames: () -> [String]
   private let _scores: () -> [Double]
   private let _avatarURLs: () -> [URL?]
   private let _managerNames: () -> [String]

   init<T: FantasyMatchup>(_ matchup: T) {
	  _teamNames = { matchup.teamNames }
	  _scores = { matchup.scores }
	  _avatarURLs = { matchup.avatarURLs }
	  _managerNames = { matchup.managerNames }
   }

   var teamNames: [String] { _teamNames() }
   var scores: [Double] { _scores() }
   var avatarURLs: [URL?] { _avatarURLs() }
   var managerNames: [String] { _managerNames() }
}


struct SleeperMatchup: Codable, FantasyMatchup {
   var teamNames: [String]
   var scores: [Double]
   var avatarURLs: [URL?]
   var managerNames: [String]

   enum CodingKeys: String, CodingKey {
	  case teamNames = "roster_id"
	  case scores = "points"
	  case avatarURLs = "avatar"
	  case managerNames = "manager"
   }
}

class FantasyMatchupViewModel: ObservableObject {
   struct SleeperLeague: Identifiable {
	  var id: String { leagueID }
	  let leagueID: String
	  let name: String
   }

   @Published var espnFantasyModel: ESPNFantasy.ESPNFantasyModel?
   @Published var matchups: [any FantasyMatchup] = []
   @Published var isLoading: Bool = false
   @Published var errorMessage: String? = nil
   @Published var leagueID: String = ""
   @Published var sleeperLeagues: [SleeperLeague] = []
   @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
   @Published var selectedWeek: Int = {
	  let firstWeek = 36
	  let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
	  let offset = currentWeek >= firstWeek ? currentWeek - firstWeek + 1 : 0
	  return min(max(1, offset), 17)
   }()

   private var cancellables = Set<AnyCancellable>()

   func fetchFantasyMatchupViewModelMatchups() {
	  isLoading = true
	  errorMessage = nil
	  matchups.removeAll()

	  if leagueID == AppConstants.ESPNLeagueID {
		 fetchFantasyData(forWeek: selectedWeek)
	  } else {
		 fetchFantasyMatchupViewModelSleeperMatchups()
	  }
   }

   func fetchFantasyData(forWeek week: Int) {
	  guard leagueID == AppConstants.ESPNLeagueID,
			let url = URL(string: "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/\(selectedYear)/segments/0/leagues/\(leagueID)?view=mMatchupScore&view=mLiveScoring&view=mRoster&scoringPeriodId=\(week)") else {
		 print("Invalid league ID for ESPN data fetch.")
		 isLoading = false
		 return
	  }

	  var request = URLRequest(url: url)
	  request.addValue("application/json", forHTTPHeaderField: "Accept")
	  request.addValue("SWID=\(AppConstants.SWID); espn_s2=\(AppConstants.ESPN_S2)", forHTTPHeaderField: "Cookie")

	  URLSession.shared.dataTaskPublisher(for: request)
		 .map { $0.data }
		 .tryMap { data -> Data in
			print("DP: Raw ESPN Response: \(String(data: data, encoding: .utf8) ?? "No Data")")
			return data
		 }
		 .decode(type: ESPNFantasy.ESPNFantasyModel.self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { [weak self] completion in
			self?.isLoading = false
			if case .failure(let error) = completion {
			   print("Error fetching ESPN data: \(error)")
			   self?.errorMessage = "Error fetching ESPN data: \(error.localizedDescription)"
			}
		 }, receiveValue: { [weak self] model in
			self?.espnFantasyModel = model
			self?.matchups = model.schedule.map { AnyFantasyMatchup($0) } // Use type-erased wrapper
			self?.isLoading = false
		 })
		 .store(in: &cancellables)
   }




   func fetchFantasyMatchupViewModelSleeperLeagues(forUserID userID: String) {
	  if let url = URL(string: "https://api.sleeper.app/v1/user/\(userID)/leagues/nfl/\(selectedYear)") {
		 URLSession.shared.dataTaskPublisher(for: url)
			.map { $0.data }
			.decode(type: [SleeperLeagueResponse].self, decoder: JSONDecoder())
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
			   if case .failure(let error) = completion {
				  self?.errorMessage = "Error fetching Sleeper leagues: \(error.localizedDescription)"
			   }
			}, receiveValue: { [weak self] leagues in
			   self?.sleeperLeagues = leagues.map { SleeperLeague(leagueID: $0.leagueID, name: $0.name) }
			   if let firstLeague = self?.sleeperLeagues.first {
				  self?.leagueID = firstLeague.leagueID
				  self?.fetchFantasyMatchupViewModelMatchups()
			   }
			})
			.store(in: &cancellables)
	  }
   }

   private func fetchFantasyMatchupViewModelSleeperMatchups() {
	  guard leagueID != AppConstants.ESPNLeagueID else { return }
	  let week = selectedWeek

	  if let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)/matchups/\(week)") {
		 URLSession.shared.dataTaskPublisher(for: url)
			.map { response -> Data in
			   return response.data
			}
			.decode(type: [SleeperMatchup].self, decoder: JSONDecoder())
			.map { $0 as [any FantasyMatchup] }
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
			   self?.isLoading = false
			   if case .failure(let error) = completion {
				  self?.errorMessage = "Error fetching Sleeper data: \(error.localizedDescription)"
			   }
			}, receiveValue: { [weak self] matchups in
			   self?.matchups = matchups
			})
			.store(in: &cancellables)
	  }
   }
}


struct SleeperLeagueResponse: Codable {
   let leagueID: String
   let name: String

   enum CodingKeys: String, CodingKey {
	  case leagueID = "league_id"
	  case name
   }
}

struct FantasyMatchupListView: View {
   @ObservedObject var fantasyViewModel: FantasyMatchupViewModel

   var body: some View {
	  VStack(alignment: .leading) {
		 Picker("Select Year", selection: $fantasyViewModel.selectedYear) {
			ForEach(2015...Calendar.current.component(.year, from: Date()), id: \.self) { year in
			   Text(String(year)).tag(year)
			}
		 }
		 .pickerStyle(MenuPickerStyle())
		 .padding()
		 .onChange(of: fantasyViewModel.selectedYear) { _ in
			fantasyViewModel.fetchFantasyData(forWeek: fantasyViewModel.selectedWeek)
		 }

		 Picker("Select Week", selection: $fantasyViewModel.selectedWeek) {
			ForEach(1..<18) { week in
			   Text("Week \(week)").tag(week)
			}
		 }
		 .pickerStyle(MenuPickerStyle())
		 .padding()
		 .onChange(of: fantasyViewModel.selectedWeek) { _ in
			fantasyViewModel.fetchFantasyData(forWeek: fantasyViewModel.selectedWeek)
		 }

		 Picker("Select League", selection: $fantasyViewModel.leagueID) {
			Text("Select League").tag("") // Placeholder option
			ForEach(fantasyViewModel.sleeperLeagues, id: \.leagueID) { league in
			   Text(league.name).tag(league.leagueID)
			}
			Text("ESPN League").tag(AppConstants.ESPNLeagueID)
		 }
		 .pickerStyle(MenuPickerStyle())
		 .padding()
		 .onChange(of: fantasyViewModel.leagueID) { _ in
			fantasyViewModel.fetchFantasyData(forWeek: fantasyViewModel.selectedWeek)
		 }

		 if fantasyViewModel.isLoading {
			ProgressView("Loading matchups...")
		 } else if let errorMessage = fantasyViewModel.errorMessage {
			Text("Error: \(errorMessage)")
		 } else {
			List(fantasyViewModel.matchups, id: \.teamNames) { matchup in
			   VStack(alignment: .leading, spacing: 16) {
				  HStack {
					 VStack(alignment: .leading) {
						Text(matchup.teamNames[0])
						   .font(.headline)
						Text("Score: \(matchup.scores[0], specifier: "%.2f")")
						   .font(.subheadline)
					 }
					 Spacer()
					 VStack(alignment: .trailing) {
						Text(matchup.teamNames[1])
						   .font(.headline)
						Text("Score: \(matchup.scores[1], specifier: "%.2f")")
						   .font(.subheadline)
					 }
				  }
				  HStack {
					 if let avatarURL = matchup.avatarURLs[0] {
						AsyncImage(url: avatarURL) { image in
						   image.resizable()
							  .frame(width: 50, height: 50)
							  .clipShape(Circle())
						} placeholder: {
						   ProgressView()
						}
					 }
					 Text(matchup.managerNames[0])
						.font(.caption)
					 Spacer()
					 if let avatarURL = matchup.avatarURLs[1] {
						AsyncImage(url: avatarURL) { image in
						   image.resizable()
							  .frame(width: 50, height: 50)
							  .clipShape(Circle())
						} placeholder: {
						   ProgressView()
						}
					 }
					 Text(matchup.managerNames[1])
						.font(.caption)
				  }
			   }
			   .padding()
			}
		 }
	  }
	  .onAppear {
		 fantasyViewModel.fetchFantasyMatchupViewModelSleeperLeagues(forUserID: AppConstants.GpSleeperID)
	  }
	  .padding()
   }
}
