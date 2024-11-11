import SwiftUI
import Combine

class FantasyMatchupViewModel: ObservableObject {
   @Published var fantasyModel: FantasyScores.FantasyModel?
   @Published var matchups: [AnyFantasyMatchup] = []
   @Published var isLoading: Bool = false
   @Published var leagueName: String = "" // holder to show league name on detailView
   @Published var lastSelectedMatchup: AnyFantasyMatchup?
   @Published var errorMessage: String? = nil
   @Published var leagueID: String = AppConstants.ESPNLeagueID
   @Published var sleeperLeagues: [FantasyScores.SleeperLeagueResponse] = []
   @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())

   @Published var selectedWeek: Int = {
	  let firstWeek = 36 // Adjust for the NFL season's starting week
	  let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
	  var offset = currentWeek >= firstWeek ? currentWeek - firstWeek + 1 : 0

	  // Check if today is Monday or Tuesday and adjust the offset if needed
	  let today = Date()
	  let weekday = Calendar.current.component(.weekday, from: today) // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
	  if weekday == 2 || weekday == 3 { // Monday or Tuesday
		 offset -= 1
	  }

	  return min(max(1, offset), 17) // Clamp the week between 1 and 17
   }()


   var sleeperScoringSettings: [String: Double] = [:]
   var sleeperPlayers: [String: FantasyScores.SleeperPlayer] = [:]
   var rosterIDToManagerName: [Int: String] = [:]
   var rosterIDToTeamName: [Int: String] = [:]
   

   private var cancellables = Set<AnyCancellable>()
   private var refreshTimer: AnyCancellable?
   private var lastLoadedLeagueID: String?
   private var lastLoadedWeek: Int?

   func setupRefreshTimer(with interval: Int) {
	  refreshTimer?.cancel()
	  guard interval > 0 else { return }
	  refreshTimer = Timer.publish(every: TimeInterval(interval), on: .main, in: .common)
		 .autoconnect()
		 .sink { [weak self] _ in
			self?.fetchFantasyMatchupViewModelMatchups()
		 }
   }

   func fetchFantasyMatchupViewModelMatchups() {
	  // Only refetch if leagueID or selectedWeek has changed
	  if leagueID == lastLoadedLeagueID, selectedWeek == lastLoadedWeek {
		 return
	  }

	  isLoading = true
	  errorMessage = nil
	  matchups.removeAll()

	  if leagueID == AppConstants.ESPNLeagueID {
		 fetchFantasyData(forWeek: selectedWeek)
	  } else {
		 // Fetch users and rosters before processing matchups
		 fetchSleeperLeagueUsersAndRosters { [weak self] in
			self?.fetchSleeperMatchups()
		 }
	  }

	  // Update the last loaded league and week
	  lastLoadedLeagueID = leagueID
	  lastLoadedWeek = selectedWeek
   }


   func getScore(for matchup: AnyFantasyMatchup, teamIndex: Int) -> Double {
	  return matchup.scores[teamIndex]
   }


   func getRoster(for matchup: AnyFantasyMatchup, teamIndex: Int, isBench: Bool) -> [FantasyScores.FantasyModel.Team.PlayerEntry] {
	  let teamId = teamIndex == 0 ? matchup.awayTeamID : matchup.homeTeamID
	  guard let team = fantasyModel?.teams.first(where: { $0.id == teamId }) else { return [] }

	  // Define the active slots in the specified order
	  let activeSlotsOrder: [Int] = [0, 2, 3, 4, 5, 6, 23, 16, 17] // QB, RB, RB, WR, WR, TE, FLEX, D/ST, K
	  let benchSlots = Array(20...30) // Typical ESPN bench slots range
	  let relevantSlots = isBench ? benchSlots : activeSlotsOrder

	  // Create a slot order dictionary for sorting
	  let slotOrder = Dictionary(uniqueKeysWithValues: relevantSlots.enumerated().map { ($1, $0) })

	  return team.roster?.entries
		 .filter { relevantSlots.contains($0.lineupSlotId) }
		 .sorted { (slotOrder[$0.lineupSlotId] ?? Int.max) < (slotOrder[$1.lineupSlotId] ?? Int.max) } ?? []
   }

   func getPlayerScore(for player: FantasyScores.FantasyModel.Team.PlayerEntry, week: Int) -> Double {
	  return player.playerPoolEntry.player.stats.first { $0.scoringPeriodId == week && $0.statSourceId == 0 }?.appliedTotal ?? 0.0
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
		 .decode(type: FantasyScores.FantasyModel.self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { [weak self] completion in
			self?.isLoading = false
			if case .failure(let error) = completion {
			   print("Error fetching ESPN data: \(error)")
			   self?.errorMessage = "Error fetching ESPN data: \(error.localizedDescription)"
			}
		 }, receiveValue: { [weak self] model in
			guard let self = self else { return }
			self.fantasyModel = model
			self.processESPNMatchups(model: model)
			self.isLoading = false
		 })
		 .store(in: &cancellables)
   }

   private func processESPNMatchups(model: FantasyScores.FantasyModel) {
	  var processedMatchups: [AnyFantasyMatchup] = []

	  for matchup in model.schedule.filter({ $0.matchupPeriodId == selectedWeek }) {
		 let homeTeamId = matchup.home.teamId
		 let awayTeamId = matchup.away.teamId
		 let homeTeam = model.teams.first { $0.id == homeTeamId }
		 let awayTeam = model.teams.first { $0.id == awayTeamId }

		 let homeTeamName = homeTeam?.name ?? "Unknown"
		 let awayTeamName = awayTeam?.name ?? "Unknown"

		 // Calculate scores
		 let homeTeamScore = homeTeam?.roster?.entries.reduce(0.0) {
			$0 + getPlayerScore(for: $1, week: selectedWeek)
		 } ?? 0.0
		 let awayTeamScore = awayTeam?.roster?.entries.reduce(0.0) {
			$0 + getPlayerScore(for: $1, week: selectedWeek)
		 } ?? 0.0

		 let fantasyMatchup = FantasyScores.FantasyMatchup(
			homeTeamName: homeTeamName,
			awayTeamName: awayTeamName,
			homeScore: homeTeamScore,
			awayScore: awayTeamScore,
			homeAvatarURL: nil,
			awayAvatarURL: nil,
			homeManagerName: homeTeamName,
			awayManagerName: awayTeamName,
			homeTeamID: homeTeamId,
			awayTeamID: awayTeamId
		 )

		 processedMatchups.append(AnyFantasyMatchup(fantasyMatchup))
	  }

	  self.matchups = processedMatchups
   }

   func fetchSleeperLeagues(forUserID userID: String) {
	  guard let url = URL(string: "https://api.sleeper.app/v1/user/\(userID)/leagues/nfl/\(selectedYear)") else { return }

	  URLSession.shared.dataTaskPublisher(for: url)
		 .map { $0.data }
		 .decode(type: [FantasyScores.SleeperLeagueResponse].self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { [weak self] completion in
			if case .failure(let error) = completion {
			   self?.errorMessage = "Error fetching Sleeper leagues: \(error.localizedDescription)"
			}
		 }, receiveValue: { [weak self] leagues in
			self?.sleeperLeagues = leagues.map { FantasyScores.SleeperLeagueResponse(leagueID: $0.leagueID, name: $0.name) }
			if let firstLeague = self?.sleeperLeagues.first {
			   self?.leagueID = firstLeague.leagueID
			   self?.fetchFantasyMatchupViewModelMatchups()
			}
		 })
		 .store(in: &cancellables)
   }

   func fetchSleeperMatchups() {
	  guard leagueID != AppConstants.ESPNLeagueID else { return }
	  let week = selectedWeek
	  print("Fetching Sleeper matchups for leagueID: \(leagueID), week: \(week)")

	  // Fetch users and rosters
	  fetchSleeperLeagueUsersAndRosters { [weak self] in
		 guard let self = self else { return }

		 guard let url = URL(string: "https://api.sleeper.app/v1/league/\(self.leagueID)/matchups/\(week)") else {
			print("Invalid URL for Sleeper matchup data.")
			return
		 }

		 URLSession.shared.dataTaskPublisher(for: url)
			.map { $0.data }
			.decode(type: [FantasyScores.SleeperMatchup].self, decoder: JSONDecoder())
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
			   self?.isLoading = false
			   if case .failure(let error) = completion {
				  print("Error decoding Sleeper data: \(error)")
				  self?.errorMessage = "Error fetching Sleeper data: \(error.localizedDescription)"
			   }
			}, receiveValue: { [weak self] sleeperMatchups in
			   guard let self = self else { return }
			   self.processSleeperMatchups(sleeperMatchups)
			})
			.store(in: &self.cancellables)
	  }
   }

   private func processSleeperMatchups(_ sleeperMatchups: [FantasyScores.SleeperMatchup]) {
	  let groupedMatchups = Dictionary(grouping: sleeperMatchups, by: { $0.matchup_id })
	  var processedMatchups: [AnyFantasyMatchup] = []

	  for (_, matchups) in groupedMatchups where matchups.count == 2 {
		 let team1 = matchups[0]
		 let team2 = matchups[1]

		 // Retrieve manager and team names from the mappings
		 let homeManagerName = self.rosterIDToManagerName[team1.roster_id] ?? "Manager \(team1.roster_id)"
		 let awayManagerName = self.rosterIDToManagerName[team2.roster_id] ?? "Manager \(team2.roster_id)"
		 let homeTeamName = self.rosterIDToTeamName[team1.roster_id] ?? homeManagerName
		 let awayTeamName = self.rosterIDToTeamName[team2.roster_id] ?? awayManagerName

		 let fantasyMatchup = FantasyScores.FantasyMatchup(
			homeTeamName: homeTeamName,
			awayTeamName: awayTeamName,
			homeScore: team1.points ?? 0,
			awayScore: team2.points ?? 0,
			homeAvatarURL: nil, // Update if you have avatar URLs
			awayAvatarURL: nil, // Update if you have avatar URLs
			homeManagerName: homeManagerName,
			awayManagerName: awayManagerName,
			homeTeamID: team1.roster_id,
			awayTeamID: team2.roster_id
		 )

		 processedMatchups.append(AnyFantasyMatchup(fantasyMatchup))
	  }

	  self.matchups = processedMatchups
   }

   func fetchSleeperLeagueUsersAndRosters(completion: @escaping () -> Void) {
	  let group = DispatchGroup()
	  var rosters: [SleeperRoster] = []
	  var users: [SleeperUser] = []

	  // Fetch rosters
	  group.enter()
	  fetchSleeperLeagueRosters(leagueID: leagueID) { result in
		 switch result {
			case .success(let fetchedRosters):
			   rosters = fetchedRosters
			case .failure(let error):
			   print("Error fetching rosters: \(error)")
		 }
		 group.leave()
	  }

	  // Fetch users
	  group.enter()
	  fetchSleeperLeagueUsers(leagueID: leagueID) { result in
		 switch result {
			case .success(let fetchedUsers):
			   users = fetchedUsers
			case .failure(let error):
			   print("Error fetching users: \(error)")
		 }
		 group.leave()
	  }

	  group.notify(queue: .main) {
		 // Create mapping for manager names and team names
		 var userIDToDisplayName: [String: String] = [:]
		 for user in users {
			userIDToDisplayName[user.user_id] = user.display_name
		 }

		 self.rosterIDToManagerName = [:]
		 self.rosterIDToTeamName = [:]

		 for roster in rosters {
			let managerName = userIDToDisplayName[roster.owner_id] ?? "Manager \(roster.roster_id)"
			self.rosterIDToManagerName[roster.roster_id] = managerName

			// Set the team name if available; fallback to the manager name
			if let teamName = roster.metadata?["team_name"] ?? roster.metadata?["team_name_update"] {
			   self.rosterIDToTeamName[roster.roster_id] = teamName
			} else {
			   self.rosterIDToTeamName[roster.roster_id] = managerName
			}
		 }

		 completion()
	  }
   }

   func fetchSleeperLeagueRosters(leagueID: String, completion: @escaping (Result<[SleeperRoster], Error>) -> Void) {
	  guard let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)/rosters") else {
		 completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
		 return
	  }

	  URLSession.shared.dataTask(with: url) { data, response, error in
		 if let error = error {
			completion(.failure(error))
			return
		 }
		 guard let data = data else {
			completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
			return
		 }
		 do {
			let rosters = try JSONDecoder().decode([SleeperRoster].self, from: data)
			completion(.success(rosters))
		 } catch {
			completion(.failure(error))
		 }
	  }.resume()
   }

   func fetchSleeperLeagueUsers(leagueID: String, completion: @escaping (Result<[SleeperUser], Error>) -> Void) {
	  guard let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)/users") else {
		 completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
		 return
	  }

	  URLSession.shared.dataTask(with: url) { data, response, error in
		 if let error = error {
			completion(.failure(error))
			return
		 }
		 guard let data = data else {
			completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
			return
		 }
		 do {
			let users = try JSONDecoder().decode([SleeperUser].self, from: data)
			completion(.success(users))
		 } catch {
			completion(.failure(error))
		 }
	  }.resume()
   }





}
