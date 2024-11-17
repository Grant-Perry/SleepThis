import SwiftUI
import Combine

class FantasyMatchupViewModel: ObservableObject {
   @Published var fantasyModel: FantasyScores.FantasyModel?
   @Published var matchups: [AnyFantasyMatchup] = []
   @Published var isLoading: Bool = false
   @Published var leagueName: String = "ESPN League"
   @Published var lastSelectedMatchup: AnyFantasyMatchup?
   @Published var errorMessage: String? = nil
   @Published var leagueID: String = AppConstants.ESPNLeagueID
   @Published var sleeperLeagues: [FantasyScores.SleeperLeagueResponse] = []
   @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
   @Published private var userAvatars: [String: URL] = [:] // Cache for user avatars

   @Published var selectedWeek: Int = {
	  let firstWeek = 36 // NFL season typically starts around week 36
	  let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
	  var offset = currentWeek >= firstWeek ? currentWeek - firstWeek + 1 : 0

	  // Check if it's Sunday or Monday - if so, stay on current week
	  let today = Date()
	  let weekday = Calendar.current.component(.weekday, from: today) // 1 = Sunday, 2 = Monday
	  if weekday == 1 || weekday == 2 { // Sunday or Monday
		 offset = max(1, offset - 1) // Stay on current week
	  }

	  return min(max(1, offset), 17) // Clamp between 1 and 17
   }()

   var sleeperScoringSettings: [String: Double] = [:]
   var sleeperPlayers: [String: FantasyScores.SleeperPlayer] = [:]
   var rosterIDToManagerName: [Int: String] = [:]
   var rosterIDToTeamName: [Int: String] = [:]
   private var rosterIDToManagerID: [Int: String] = [:]
   private var userIDs: [String: String] = [:]

   private var weeklyStats: [String: [String: Double]] = [:]
   private var sleeperLeagueSettings: [String: Any]? = nil
   private var cancellables = Set<AnyCancellable>()
   private var refreshTimer: AnyCancellable?
   private var lastLoadedLeagueID: String?
   private var lastLoadedWeek: Int?
   private let playerViewModel: PlayerViewModel

   init(playerViewModel: PlayerViewModel = PlayerViewModel()) {
	  // Initialize leagueID directly during initialization
	  self.leagueID = AppConstants.ESPNLeagueID
	  self.playerViewModel = playerViewModel

	  // Initialize data
	  playerViewModel.loadPlayersFromCache()
	  if playerViewModel.players.isEmpty {
		 playerViewModel.fetchAllPlayers()
	  }

	  // Now fetch data
	  DispatchQueue.main.async {
		 self.fetchFantasyMatchupViewModelMatchups()
		 self.fetchSleeperLeagues(forUserID: AppConstants.GpSleeperID)
	  }
   }

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
	  if leagueID == AppConstants.ESPNLeagueID {
		 // Get the correct team ID
		 let teamId = teamIndex == 0 ? matchup.homeTeamID : matchup.awayTeamID
		 guard let team = fantasyModel?.teams.first(where: { $0.id == teamId }) else { return 0.0 }

		 // Only sum active roster scores (not bench)
		 let activeSlotsOrder: [Int] = [0, 2, 3, 4, 5, 6, 23, 16, 17]

		 return team.roster?.entries
			.filter { activeSlotsOrder.contains($0.lineupSlotId) }
			.reduce(0.0) { sum, entry in
			   sum + (entry.playerPoolEntry.player.stats.first {
				  $0.scoringPeriodId == selectedWeek && $0.statSourceId == 0
			   }?.appliedTotal ?? 0.0)
			} ?? 0.0
	  } else {
		 return matchup.scores[teamIndex]
	  }
   }

   func getRoster(for matchup: AnyFantasyMatchup, teamIndex: Int, isBench: Bool) -> [FantasyScores.FantasyModel.Team.PlayerEntry] {
	  if leagueID == AppConstants.ESPNLeagueID {
		 // Keep existing ESPN implementation exactly as is
		 let teamId = teamIndex == 0 ? matchup.homeTeamID : matchup.awayTeamID
		 guard let team = fantasyModel?.teams.first(where: { $0.id == teamId }) else { return [] }

		 let activeSlotsOrder: [Int] = [0, 2, 3, 4, 5, 6, 23, 16, 17]
		 let benchSlots = Array(20...30)
		 let relevantSlots = isBench ? benchSlots : activeSlotsOrder

		 let slotOrder = Dictionary(uniqueKeysWithValues: relevantSlots.enumerated().map { ($1, $0) })

		 return team.roster?.entries
			.filter { relevantSlots.contains($0.lineupSlotId) }
			.sorted { (slotOrder[$0.lineupSlotId] ?? Int.max) < (slotOrder[$1.lineupSlotId] ?? Int.max) } ?? []
	  } else {
		 // Fixed Sleeper implementation
		 guard let sleeperMatchupData = matchup.sleeperData else { return [] }

		 // Fix the team order by swapping the index
		 let sleeperMatchup = teamIndex == 0 ? sleeperMatchupData.1 : sleeperMatchupData.0

		 let playerIds = isBench ?
		 (sleeperMatchup.players?.filter { !(sleeperMatchup.starters?.contains($0) ?? false) } ?? []) :
		 (sleeperMatchup.starters ?? [])

		 return playerIds.map { playerId in
			createPlayerEntry(from: playerId)
		 }
	  }
   }

   func getPlayerScore(for player: FantasyScores.FantasyModel.Team.PlayerEntry, week: Int) -> Double {
	  if leagueID == AppConstants.ESPNLeagueID {
		 return player.playerPoolEntry.player.stats.first { $0.scoringPeriodId == week && $0.statSourceId == 0 }?.appliedTotal ?? 0.0
	  } else {
		 // Sleeper scoring logic
		 let playerId = String(player.playerPoolEntry.player.id)
		 guard let playerStats = weeklyStats[playerId],
			   let scoringSettings = sleeperLeagueSettings else {
			print("Missing data for player \(playerId) - stats: \(weeklyStats[playerId] != nil), settings: \(sleeperLeagueSettings != nil)")
			return 0.0
		 }

		 var totalScore = 0.0
		 for (statKey, statValue) in playerStats {
			if let scoring = scoringSettings[statKey] as? Double {
			   let points = statValue * scoring
			   totalScore += points
			}
		 }
		 return totalScore
	  }
   }

   // Add function to calculate Sleeper player scores
   private func calculateSleeperPlayerScore(playerId: String) -> Double {
	  guard let playerStats = weeklyStats[playerId],
			let scoringSettings = sleeperLeagueSettings else {
		 print("Missing data for player \(playerId) - stats: \(weeklyStats[playerId] != nil), settings: \(sleeperLeagueSettings != nil)")
		 return 0.0
	  }

	  var totalScore = 0.0
	  for (statKey, statValue) in playerStats {
		 if let scoring = scoringSettings[statKey] as? Double {
			let points = statValue * scoring
			print("Stat \(statKey): \(statValue) * \(scoring) = \(points)")
			totalScore += points
		 }
	  }
	  print("Final calculated score for player \(playerId): \(totalScore)")
	  return totalScore
   }

   private func createPlayerEntry(from playerId: String) -> FantasyScores.FantasyModel.Team.PlayerEntry {
	  // Get player details from PlayerViewModel
	  let player = playerViewModel.players.first { $0.id == playerId }

	  let fullName = if let player = player {
		 "\(player.firstName ?? "") \(player.lastName ?? "")"
	  } else {
		 playerId // Fallback if player not found
	  }

	  // Get position for slot ID
	  let position = player?.position ?? "FLEX"
	  let slotId = getPositionSlotId(position: position)

	  return FantasyScores.FantasyModel.Team.PlayerEntry(
		 playerPoolEntry: .init(
			player: .init(
			   id: Int(playerId) ?? 0,
			   fullName: fullName,
			   stats: []
			)
		 ),
		 lineupSlotId: slotId
	  )
   }

   // Helper function for position slot IDs
   private func getPositionSlotId(position: String) -> Int {
	  switch position {
		 case "QB": return 0
		 case "RB": return 2
		 case "WR": return 4
		 case "TE": return 6
		 case "K": return 17
		 case "DEF": return 16
		 default: return 23 // FLEX
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

   private func fetchSleeperScoringSettings() {
	  print("Fetching scoring settings for league: \(leagueID)")
	  guard let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)") else { return }

	  URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
		 guard let data = data else {
			print("No scoring settings data received")
			return
		 }

		 do {
			let decoder = JSONDecoder()
			if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
			   let settings = json["scoring_settings"] as? [String: Any] {
			   DispatchQueue.main.async {
				  self?.sleeperLeagueSettings = settings
				  print("Scoring settings fetched: \(settings)")
				  self?.fetchSleeperWeeklyStats()
			   }
			}
		 } catch {
			print("Error decoding league settings: \(error)")
		 }
	  }.resume()
   }

   private func fetchSleeperWeeklyStats() {
	  print("Fetching Sleeper weekly stats for week \(selectedWeek)")
	  guard let url = URL(string: "https://api.sleeper.app/v1/stats/nfl/regular/\(selectedYear)/\(selectedWeek)") else { return }

	  URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
		 guard let data = data else {
			print("No weekly stats data received")
			return
		 }

		 do {
			let statsData = try JSONDecoder().decode([String: [String: Double]].self, from: data)
			DispatchQueue.main.async {
			   self?.weeklyStats = statsData
			   print("Weekly stats fetched for \(statsData.count) players")
			   self?.objectWillChange.send()
			}
		 } catch {
			print("Error decoding weekly stats: \(error)")
		 }
	  }.resume()
   }



   func fetchSleeperMatchups() {
	  guard leagueID != AppConstants.ESPNLeagueID else { return }
	  fetchSleeperScoringSettings() // This will trigger weekly stats fetch after completion
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

		 // Use team name if available, otherwise fall back to manager name
		 let homeTeamName = rosterIDToTeamName[team1.roster_id] ?? rosterIDToManagerName[team1.roster_id] ?? "Unknown Team"
		 let awayTeamName = rosterIDToTeamName[team2.roster_id] ?? rosterIDToManagerName[team2.roster_id] ?? "Unknown Team"

		 let homeManagerName = rosterIDToManagerName[team1.roster_id] ?? "Unknown Manager"
		 let awayManagerName = rosterIDToManagerName[team2.roster_id] ?? "Unknown Manager"

		 // Get avatar URLs using manager IDs
		 let homeManagerID = rosterIDToManagerID[team1.roster_id] ?? ""
		 let awayManagerID = rosterIDToManagerID[team2.roster_id] ?? ""
		 let homeAvatarURL = URL(string: "https://sleepercdn.com/avatars/\(homeManagerID)")
		 let awayAvatarURL = URL(string: "https://sleepercdn.com/avatars/\(awayManagerID)")

		 let fantasyMatchup = FantasyScores.FantasyMatchup(
			homeTeamName: homeTeamName,
			awayTeamName: awayTeamName,
			homeScore: team1.points ?? 0,
			awayScore: team2.points ?? 0,
			homeAvatarURL: homeAvatarURL,
			awayAvatarURL: awayAvatarURL,
			homeManagerName: homeManagerName,
			awayManagerName: awayManagerName,
			homeTeamID: team1.roster_id,
			awayTeamID: team2.roster_id
		 )

		 processedMatchups.append(AnyFantasyMatchup(fantasyMatchup, sleeperData: (team1, team2)))
	  }

	  DispatchQueue.main.async {
		 self.matchups = processedMatchups
	  }
   }

   private var rosterIDToManager: [Int: SleeperFantasy.Manager] = [:]


   func fetchSleeperLeagueUsersAndRosters(completion: @escaping () -> Void) {
	  // Reset mappings
	  self.userIDs = [:]
	  self.rosterIDToManagerName = [:]
	  self.rosterIDToManagerID = [:]
	  self.rosterIDToTeamName = [:]

	  print("DP - Starting to fetch users for league: \(leagueID)")

	  // Create sequential chain of operations
	  guard let usersURL = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)/users") else {
		 print("DP - Invalid users URL")
		 completion()
		 return
	  }

	  // First fetch users
	  URLSession.shared.dataTask(with: usersURL) { [weak self] data, response, error in
		 if let error = error {
			print("DP - Error fetching users: \(error)")
			completion()
			return
		 }

		 guard let data = data else {
			print("DP - No user data received")
			completion()
			return
		 }

		 do {
			let users = try JSONDecoder().decode([SleeperUser].self, from: data)
			print("DP - Successfully fetched \(users.count) users")

			// Store users first
			DispatchQueue.main.async {
			   for user in users {
				  print("DP - Processing user: \(user.display_name) with ID: \(user.user_id)")
				  self?.userIDs[user.user_id] = user.display_name
				  if let avatar = user.avatar {
					 self?.userAvatars[user.user_id] = URL(string: "https://sleepercdn.com/avatars/\(avatar)")
				  }
			   }

			   // Now fetch rosters after users are stored
			   guard let self = self,
					 let rostersURL = URL(string: "https://api.sleeper.app/v1/league/\(self.leagueID)/rosters") else {
				  print("DP - Invalid rosters URL")
				  completion()
				  return
			   }

			   URLSession.shared.dataTask(with: rostersURL) { data, response, error in
				  if let error = error {
					 print("DP - Error fetching rosters: \(error)")
					 completion()
					 return
				  }

				  guard let data = data else {
					 print("DP - No roster data received")
					 completion()
					 return
				  }

				  do {
					 let rosters = try JSONDecoder().decode([SleeperRoster].self, from: data)
					 print("DP - Successfully fetched \(rosters.count) rosters")

					 DispatchQueue.main.async {
						for roster in rosters {
						   if let ownerID = roster.owner_id {
							  print("DP - Processing roster \(roster.roster_id) for owner \(ownerID)")
							  if let displayName = self.userIDs[ownerID] {
								 print("DP - Found display name: \(displayName) for owner ID: \(ownerID)")
								 self.rosterIDToManagerName[roster.roster_id] = displayName
								 self.rosterIDToManagerID[roster.roster_id] = ownerID

								 if let teamName = roster.metadata?["team_name"] ?? roster.metadata?["team_name_update"] {
									print("DP - Using team name: \(teamName)")
									self.rosterIDToTeamName[roster.roster_id] = teamName
								 } else {
									print("DP - Using display name as team name: \(displayName)")
									self.rosterIDToTeamName[roster.roster_id] = displayName
								 }
							  }
						   }
						}

						print("DP - Final manager mappings: \(self.rosterIDToManagerName)")
						completion()
					 }
				  } catch {
					 print("DP - Error decoding rosters: \(error)")
					 completion()
				  }
			   }.resume()
			}
		 } catch {
			print("DP - Error decoding users: \(error)")
			completion()
		 }
	  }.resume()
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

   private func getPlayerName(for playerId: String) -> String {
	  // Get player name from cached player data
	  if let playerData = playerViewModel.players.first(where: { $0.id == playerId }) {
		 return "\(playerData.firstName ?? "") \(playerData.lastName ?? "")"
	  }
	  return "Unknown Player"
   }

   private func getPositionSlotId(for playerId: String) -> Int {
	  // Map Sleeper positions to our slot IDs
	  if let playerData = playerViewModel.players.first(where: { $0.id == playerId }) {
		 switch playerData.position {
			case "QB": return 0
			case "RB": return 2
			case "WR": return 4
			case "TE": return 6
			case "K": return 17
			case "DEF": return 16
			default: return 23 // FLEX
		 }
	  }
	  return 23 // Default to FLEX
   }

   private func fetchSleeperUser(userID: String) {
	  guard let url = URL(string: "https://api.sleeper.app/v1/user/\(userID)") else { return }

	  URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
		 guard let data = data,
			   let user = try? JSONDecoder().decode(SleeperUser.self, from: data) else { return }

		 DispatchQueue.main.async {
			if let avatar = user.avatar {
			   self?.userAvatars[userID] = URL(string: "https://sleepercdn.com/avatars/\(avatar)")
			   // Trigger UI update
			   self?.objectWillChange.send()
			}
		 }
	  }.resume()
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
		 default: return "Unknown"
	  }
   }

}
