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
   @Published var selectedTimerInterval: Int = 0  // Move from view to ViewModel

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
   // For Sleeper projections
   private var sleeperPlayerProjections: [String: Double] = [:]
   // For ESPN projections
   private var espnPlayerProjections: [Int: Double] = [:]
   
   // Team projected scores
   private var teamProjectedScores: [Int: Double] = [:] // Keyed by team ID or roster ID
   private var weeklyStats: [String: [String: Double]] = [:]
   private var weeklyProjections: [String: [String: Double]] = [:]
   private var espnProjections: [Int: Double] = [:]  // playerID: projectedPoints

   private var sleeperLeagueSettings: [String: Any]? = nil
   private var cancellables = Set<AnyCancellable>()
   private var refreshTimer: AnyCancellable?
   private var lastLoadedLeagueID: String?
   private var lastLoadedWeek: Int?
   private let playerViewModel: PlayerViewModel
   
   // Add playerViewModel to init
   init(playerViewModel: PlayerViewModel = PlayerViewModel()) {
	  self.playerViewModel = playerViewModel
	  
	  // Initialize playerViewModel data
	  playerViewModel.loadPlayersFromCache()
	  if playerViewModel.players.isEmpty {
		 playerViewModel.fetchAllPlayers()
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

   func getScore(for matchup: AnyFantasyMatchup, teamIndex: Int) -> Double {
	  let adjustedTeamIndex = leagueID == AppConstants.ESPNLeagueID ? (teamIndex == 0 ? 1 : 0) : teamIndex
	  guard let sleeperMatchupData = matchup.sleeperData else { return 0.0 }
	  let sleeperMatchup = adjustedTeamIndex == 0 ? sleeperMatchupData.1 : sleeperMatchupData.0
	  
	  let activePlayerIds = sleeperMatchup.starters ?? []
	  let totalScore = activePlayerIds.reduce(0.0) { total, playerId in
		 let playerScore = weeklyStats[playerId]?["pts_ppr"] ?? 0.0
		 
		 // Debug Print (DP)
		 let player = playerViewModel.players.first { $0.id == playerId }
		 let playerName = player?.fullName ?? "Unknown Player"
		 let playerPosition = player?.position ?? "Unknown"
		 print("[DP] Player Name: \(playerName), Pos: \(playerPosition), Score: \(playerScore)")
		 
		 return total + playerScore
	  }
	  
	  print("[DEBUG] Total Score for Sleeper Roster \(sleeperMatchup.roster_id): \(totalScore)")
	  return totalScore
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
			let url = URL(string: "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/\(selectedYear)/segments/0/leagues/\(leagueID)?view=mMatchupScore&view=mMatchup&view=mLiveScoring&view=mRoster&scoringPeriodId=\(week)") else {
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
	  print("Processing \(sleeperMatchups.count) Sleeper matchups")
	  let groupedMatchups = Dictionary(grouping: sleeperMatchups, by: { $0.matchup_id })
	  var processedMatchups: [AnyFantasyMatchup] = []
	  
	  for (_, matchups) in groupedMatchups where matchups.count == 2 {
		 let team1 = matchups[0]
		 let team2 = matchups[1]
		 
		 print("Processing matchup between roster_ids: \(team1.roster_id) and \(team2.roster_id)")
		 
		 // Get names from mappings
		 let homeManagerName = self.rosterIDToManagerName[team1.roster_id] ?? "Manager \(team1.roster_id)"
		 let awayManagerName = self.rosterIDToManagerName[team2.roster_id] ?? "Manager \(team2.roster_id)"
		 let homeTeamName = self.rosterIDToTeamName[team1.roster_id] ?? homeManagerName
		 let awayTeamName = self.rosterIDToTeamName[team2.roster_id] ?? awayManagerName
		 
		 let fantasyMatchup = FantasyScores.FantasyMatchup(
			homeTeamName: homeTeamName,
			awayTeamName: awayTeamName,
			homeScore: team1.points ?? 0,
			awayScore: team2.points ?? 0,
			homeAvatarURL: nil,
			awayAvatarURL: nil,
			homeManagerName: homeManagerName,
			awayManagerName: awayManagerName,
			homeTeamID: team1.roster_id,
			awayTeamID: team2.roster_id
		 )
		 
		 // Create AnyFantasyMatchup with Sleeper data
		 processedMatchups.append(AnyFantasyMatchup(fantasyMatchup, sleeperData: (team1, team2)))
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
			// Handle null owner_id
			if let ownerId = roster.owner_id {
			   let managerName = userIDToDisplayName[ownerId] ?? "Manager \(roster.roster_id)"
			   self.rosterIDToManagerName[roster.roster_id] = managerName
			   
			   // Set the team name if available; fallback to the manager name
			   if let teamName = roster.metadata?["team_name"] ?? roster.metadata?["team_name_update"] {
				  self.rosterIDToTeamName[roster.roster_id] = teamName
			   } else {
				  self.rosterIDToTeamName[roster.roster_id] = managerName
			   }
			} else {
			   // Handle case where owner_id is null
			   let defaultName = "Manager \(roster.roster_id)"
			   self.rosterIDToManagerName[roster.roster_id] = defaultName
			   self.rosterIDToTeamName[roster.roster_id] = defaultName
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
   
   func getPlayerName(for playerId: String) -> String {
	  // Get player name from cached player data
	  if let playerData = playerViewModel.players.first(where: { $0.id == playerId }) {
		 return "\(playerData.firstName ?? "") \(playerData.lastName ?? "")"
	  }
	  return "Unknown Player"
   }
   
   func getPositionSlotId(for playerId: String) -> Int {
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
   
   private func fetchSleeperProjections(completion: @escaping () -> Void) {
	  guard let url = URL(string: "https://api.sleeper.app/v1/projections/nfl/regular/\(selectedYear)/\(selectedWeek)") else {
		 print("Invalid URL for Sleeper projections.")
		 completion()
		 return
	  }
	  
	  URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
		 defer { completion() }
		 guard let self = self else { return }
		 
		 if let error = error {
			print("Error fetching Sleeper projections: \(error)")
			return
		 }
		 
		 guard let data = data else {
			print("No data received for Sleeper projections.")
			return
		 }
		 
		 // Log the raw API response for debugging
		 if let jsonString = String(data: data, encoding: .utf8) {
			print("[DEBUG] Sleeper Projections API Response: \(jsonString)")
		 }
		 
		 do {
			let projections = try JSONDecoder().decode([String: [String: Double]].self, from: data)
			DispatchQueue.main.async {
			   for (playerId, stats) in projections {
				  if let projectedPoints = stats["pts_ppr"] {
					 self.sleeperPlayerProjections[playerId] = projectedPoints
				  }
			   }
			   print("[DEBUG] Sleeper projections fetched for \(self.sleeperPlayerProjections.count) players.")
			}
		 } catch {
			print("Error decoding Sleeper projections: \(error)")
		 }
	  }.resume()
   }

   private func getESPNProjectedScore(for matchup: AnyFantasyMatchup, teamIndex: Int) -> Double {
	  let teamId = teamIndex == 0 ? matchup.homeTeamID : matchup.awayTeamID
	  if let projectedScore = teamProjectedScores[teamId] {
		 return projectedScore
	  }
	  
	  guard let team = fantasyModel?.teams.first(where: { $0.id == teamId }) else { return 0.0 }
	  
	  // Only process active roster slots
	  let activeSlots: Set<Int> = [0, 2, 3, 4, 5, 6, 23, 16, 17]
	  print("[DEBUG] Calculating ESPN Projected Score for Team \(teamId):")
	  
	  let activeEntries = team.roster?.entries.filter { activeSlots.contains($0.lineupSlotId) } ?? []
	  let projectedTotal = activeEntries.reduce(0.0) { total, entry in
		 let projectedPoints = entry.playerPoolEntry.player.stats.first {
			$0.scoringPeriodId == selectedWeek && $0.statSourceId == 1
		 }?.appliedTotal ?? 0.0
		 
		 // Fetch player details
		 let playerName = entry.playerPoolEntry.player.fullName
		 let playerPosition = positionString(entry.lineupSlotId)
		 
		 // DP Statement
		 print("[DP] Player Name: \(playerName), Pos: \(playerPosition), Score: \(projectedPoints)")
		 
		 return total + projectedPoints
	  }
	  
	  teamProjectedScores[teamId] = projectedTotal
	  print("[DEBUG] Total Projected Score for Team \(teamId): \(projectedTotal)")
	  return projectedTotal
   }
   
   
   
   private func getSleeperProjectedScore(for matchup: AnyFantasyMatchup, teamIndex: Int) -> Double {
	  let adjustedTeamIndex = leagueID == AppConstants.ESPNLeagueID ? (teamIndex == 0 ? 1 : 0) : teamIndex
	  guard let sleeperMatchupData = matchup.sleeperData else { return 0.0 }
	  let sleeperMatchup = adjustedTeamIndex == 0 ? sleeperMatchupData.1 : sleeperMatchupData.0
	  
	  let activePlayerIds = sleeperMatchup.starters ?? []
	  let projectedTotal = activePlayerIds.reduce(0.0) { total, playerId in
		 let playerProjection = sleeperPlayerProjections[playerId] ?? 0.0
		 
		 // Debug Print (DP)
		 let player = playerViewModel.players.first { $0.id == playerId }
		 let playerName = player?.fullName ?? "Unknown Player"
		 let playerPosition = player?.position ?? "Unknown"
		 print("[DP] Player Name: \(playerName), Pos: \(playerPosition), Projected Score: \(playerProjection)")
		 
		 return total + playerProjection
	  }
	  
	  print("[DEBUG] Total Projected Score for Sleeper Roster \(sleeperMatchup.roster_id): \(projectedTotal)")
	  return projectedTotal
   }
   
   private func positionString(_ lineupSlotId: Int) -> String {
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

   private func fetchProjections() {
	  if leagueID == AppConstants.ESPNLeagueID {
		 fetchESPNProjections()
	  } else {
		 fetchSleeperProjections()
	  }
   }

   private func fetchSleeperProjections() {
	  guard let url = URL(string: "https://api.sleeper.app/v1/projections/nfl/\(selectedYear)/\(selectedWeek)") else { return }

	  URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
		 guard let data = data else {
			print("No projection data received")
			return
		 }

		 do {
			let projections = try JSONDecoder().decode([String: [String: Double]].self, from: data)
			DispatchQueue.main.async {
			   self?.weeklyProjections = projections
			   self?.objectWillChange.send()
			}
		 } catch {
			print("Error decoding projections: \(error)")
		 }
	  }.resume()
   }

   private func fetchESPNProjections() {
	  // ESPN projections are included in the main fantasy data
	  // We just need to extract them from the player stats
	  guard let model = fantasyModel else { return }

	  var projections: [Int: Double] = [:]

	  for team in model.teams {
		 guard let entries = team.roster?.entries else { continue }

		 for entry in entries {
			let playerId = entry.playerPoolEntry.player.id
			if let projection = entry.playerPoolEntry.player.stats.first(where: {
			   $0.scoringPeriodId == selectedWeek && $0.statSourceId == 1  // statSourceId 1 is for projections
			})?.appliedTotal {
			   projections[playerId] = projection
			}
		 }
	  }

	  espnProjections = projections
	  objectWillChange.send()
   }

   // Add methods to get projected scores - Gp.
   func getProjectedScore(for matchup: AnyFantasyMatchup, teamIndex: Int) -> Double {
	  if leagueID == AppConstants.ESPNLeagueID {
		 let teamId = teamIndex == 0 ? matchup.awayTeamID : matchup.homeTeamID
		 guard let team = fantasyModel?.teams.first(where: { $0.id == teamId }) else { return 0.0 }

		 return team.roster?.entries.reduce(0.0) { total, entry in
			total + (espnProjections[entry.playerPoolEntry.player.id] ?? 0.0)
		 } ?? 0.0
	  } else {
		 guard let sleeperMatchupData = matchup.sleeperData else { return 0.0 }
		 let sleeperMatchup = teamIndex == 0 ? sleeperMatchupData.0 : sleeperMatchupData.1

		 return (sleeperMatchup.starters ?? []).reduce(0.0) { total, playerId in
			if let playerStats = weeklyProjections[playerId] {
			   let projectedPoints = calculateSleeperProjectedPoints(stats: playerStats)
			   return total + projectedPoints
			}
			return total
		 }
	  }
   }

   private func calculateSleeperProjectedPoints(stats: [String: Double]) -> Double {
	  var total = 0.0
	  for (statKey, statValue) in stats {
		 if let scoring = sleeperLeagueSettings?[statKey] as? Double {
			total += statValue * scoring
		 }
	  }
	  return total
   }

   // Add method to calculate win probability - Gp.
   func getWinProbability(for matchup: AnyFantasyMatchup, teamIndex: Int) -> Double {
	  let team0Projected = getProjectedScore(for: matchup, teamIndex: 0)
	  let team1Projected = getProjectedScore(for: matchup, teamIndex: 1)

	  // Simple probability calculation based on projected scores
	  let totalProjected = team0Projected + team1Projected
	  if totalProjected == 0 { return 50.0 }

	  let probability = teamIndex == 0 ?
	  (team0Projected / totalProjected) * 100 :
	  (team1Projected / totalProjected) * 100

	  return min(max(probability, 0), 100)  // Clamp between 0 and 100
   }

   // Modify fetchFantasyMatchupViewModelMatchups to include projections - Gp.
   func fetchFantasyMatchupViewModelMatchups() {
	  if leagueID == lastLoadedLeagueID, selectedWeek == lastLoadedWeek {
		 return
	  }

	  isLoading = true
	  errorMessage = nil
	  matchups.removeAll()

	  // Add projection fetching
	  fetchProjections()

	  if leagueID == AppConstants.ESPNLeagueID {
		 fetchFantasyData(forWeek: selectedWeek)
	  } else {
		 fetchSleeperLeagueUsersAndRosters { [weak self] in
			self?.fetchSleeperMatchups()
		 }
	  }

	  lastLoadedLeagueID = leagueID
	  lastLoadedWeek = selectedWeek
   }

   func setupRefreshTimer() {
	  refreshTimer?.cancel()
	  guard selectedTimerInterval > 0 else { return }
	  refreshTimer = Timer.publish(every: TimeInterval(selectedTimerInterval), on: .main, in: .common)
		 .autoconnect()
		 .sink { [weak self] _ in
			self?.fetchFantasyMatchupViewModelMatchups()
		 }
   }

   

}


