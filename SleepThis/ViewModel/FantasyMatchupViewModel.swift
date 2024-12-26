import SwiftUI
import Combine

class FantasyMatchupViewModel: ObservableObject {
   // Your imports remain the same

   @Published var managerRecords: [String: (wins: Int, losses: Int, ties: Int)] = [:]
   @Published var managerRanks: [String: Int] = [:]

   @Published var sleeperTeamRecords: [Int: TeamRecord] = [:]

   @Published var fantasyModel: FantasyScores.FantasyModel?
   @Published var selectedManagerID: String = AppConstants.GpSleeperID
   @Published var selectedSleeperManagerID: String = AppConstants.GpSleeperID
   @Published var selectedESPNManagerID: String = "" // AppConstants.GpESPNID
   @Published var playerStats: [String: [String: Double]] = [:]
   @Published var currentManagerLeagues: [FantasyScores.AnyLeagueResponse] = []
   @Published var espnLeagues: [ESPNLeague] = []
   @Published var matchups: [AnyFantasyMatchup] = []
   @Published var isLoading: Bool = false
   @Published var leagueName: String = "ESPN League"
   @Published var lastSelectedMatchup: AnyFantasyMatchup?
   @Published var errorMessage: String? = nil
   @Published var leagueID: String = AppConstants.ESPNLeagueID[1]
   @Published var sleeperLeagues: [FantasyScores.SleeperLeagueResponse] = []
   @Published var userAvatars: [String: URL] = [:] // Cache for user avatars
   @Published var espnManagerID: String?
   @Published var nflRosterViewModel = NFLRosterViewModel()
   @Published var selectedYear: Int = Calendar.current.component(.year, from: Date()) {
	  didSet {
		 FantasyMatchups.FantasyScoreboardModel.shared.getScoreboardData(forWeek: selectedWeek, forYear: selectedYear, forceRefresh: true) { [weak self] response in
		 }
	  }
   }

   @Published var selectedWeek: Int = {
	  // Check debug mode first
	  if AppConstants.debug {
		 return 16 // Default to week 16 in debug mode
	  }

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
   }() {
	  didSet {
		 FantasyMatchups.FantasyScoreboardModel.shared.getScoreboardData(forWeek: selectedWeek, forYear: selectedYear, forceRefresh: true) { [weak self] response in
		 }
	  }
   }

   var originalManagerLeagues: [FantasyScores.AnyLeagueResponse] = []
   var sleeperScoringSettings: [String: Double] = [:]
   var sleeperPlayers: [String: FantasyScores.SleeperPlayer] = [:]
   var rosterIDToManagerName: [Int: String] = [:]
   var rosterIDToTeamName: [Int: String] = [:]
   var rosterIDToManagerID: [Int: String] = [:]
   var userIDs: [String: String] = [:]

   private var weeklyStats: [String: [String: Double]] = [:]
   private var sleeperLeagueSettings: [String: Any]? = nil
   var cancellables = Set<AnyCancellable>()
   private var refreshTimer: AnyCancellable?
   private var lastLoadedLeagueID: String?
   private var lastLoadedWeek: Int?
   private let playerViewModel: PlayerViewModel
   private var rosterIDToManager: [Int: SleeperFantasy.Manager] = [:]

   init(playerViewModel: PlayerViewModel = PlayerViewModel()) {
	  // Initialize leagueID directly during initialization
	  self.leagueID = AppConstants.ESPNLeagueID[1]
	  self.playerViewModel = playerViewModel

	  // Initialize data
	  playerViewModel.loadPlayersFromCache()
	  if playerViewModel.players.isEmpty {
		 playerViewModel.fetchAllPlayers()
	  }

	  // Now fetch data
	  DispatchQueue.main.async {
		 self.fetchESPNManagerLeagues(forUserID: self.selectedManagerID)
	  }

	  // Call this method to fetch NFL roster data
	  fetchNFLRosterData()
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

   func handlePickerChange(newLeagueID: String) {
	  // Cancel existing timer
	  refreshTimer?.cancel()

	  // Update leagueID
	  self.leagueID = newLeagueID
	  print("DP - League ID changed to: \(newLeagueID)")

	  // Update leagueName
	  updateLeagueName()

	  // Clear existing matchups
	  matchups = []

	  // Fetch new data immediately
	  fetchFantasyMatchupViewModelMatchups()

	  // Do not restart the timer here
	  // The timer will be set up when the user changes the refresh interval

	  // Trigger UI update
	  objectWillChange.send()
   }

   func fetchFantasyMatchupViewModelMatchups() {
	  guard !leagueID.isEmpty else {
		 print("DP - Error: League ID is empty.")
		 return
	  }

	  isLoading = true
	  errorMessage = nil

	  if let league = currentManagerLeagues.first(where: { $0.id == leagueID }) {
		 print("DP - Fetching data for league: \(league.name)")

		 switch league.type {
			case .espn:
			   fetchFantasyData(forWeek: selectedWeek)
			case .sleeper:
			   fetchSleeperMatchups()
		 }
	  } else {
		 print("DP - Error: League with ID \(leagueID) not found.")
		 isLoading = false
	  }
   }

   func getScore(for matchup: AnyFantasyMatchup, teamIndex: Int) -> Double {

	  if leagueID == AppConstants.ESPNLeagueID[0] {
		 // ESPN scoring
		 let teamId = teamIndex == 0 ? matchup.awayTeamID : matchup.homeTeamID
		 guard let team = fantasyModel?.teams.first(where: { $0.id == teamId }) else { return 0.0 }
		 return calculateESPNTeamActiveScore(team: team, week: selectedWeek)
	  } else {
		 // Sleeper scoring
		 let sleeperMatchup = teamIndex == 0 ? matchup.sleeperData?.0 : matchup.sleeperData?.1
		 return calculateSleeperTeamScore(matchup: sleeperMatchup)
	  }
   }

   func calculateESPNTeamActiveScore(team: FantasyScores.FantasyModel.Team?, week: Int) -> Double {
	  guard let team = team else { return 0.0 }
	  let activeSlotsOrder: [Int] = [0, 2, 3, 4, 5, 6, 23, 16, 17]

	  return team.roster?.entries
		 .filter { activeSlotsOrder.contains($0.lineupSlotId) }
		 .reduce(0.0) { sum, entry in
			sum + getPlayerScore(for: entry, week: week)
		 } ?? 0.0
   }

   func calculateSleeperTeamScore(matchup: FantasyScores.SleeperMatchup?) -> Double {
	  guard let matchup = matchup, let starters = matchup.starters else { return 0.0 }

	  return starters.reduce(0.0) { total, playerId in
		 total + getSleeperPlayerScore(for: playerId, week: selectedWeek)
	  }
   }

   func getSleeperPlayerScore(for playerId: String, week: Int) -> Double {
	  guard let playerStats = playerStats[playerId] else { return 0.0 }

	  var totalScore = 0.0
	  for (statKey, statValue) in playerStats {
		 if let scoring = sleeperLeagueSettings?[statKey] as? Double {
			totalScore += statValue * scoring
		 }
	  }
	  return totalScore
   }

   // Update the fetchSleeperMatchups function
   func fetchSleeperMatchups() {
	  guard leagueID != AppConstants.ESPNLeagueID[1] else { return }
	  fetchSleeperScoringSettings() // Will trigger weekly stats fetch
	  let week = selectedWeek
	  print("Fetching Sleeper matchups for leagueID: \(leagueID), week: \(week)")

	  fetchSleeperLeagueUsersAndRosters { [weak self] in
		 guard let self = self else { return }

		 guard let url = URL(string: "https://api.sleeper.app/v1/league/\(self.leagueID)/matchups/\(week)") else {
			print("Invalid URL for Sleeper matchup data.")
			self.isLoading = false
			self.errorMessage = "Sorry, no matchups available\nfor \(self.leagueName) in Week \(week)."
			return
		 }

		 URLSession.shared.dataTaskPublisher(for: url)
			.map { $0.data }
			.decode(type: [FantasyScores.SleeperMatchup].self, decoder: JSONDecoder())
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
			   self?.isLoading = false
			   if case .failure(_) = completion {
				  print("Error decoding Sleeper data")
				  self?.errorMessage = "Sorry, no matchups available\nfor \(self?.leagueName ?? "this league") in Week \(week)."
				  self?.currentManagerLeagues.removeAll { $0.id == self?.leagueID }
			   }
			}, receiveValue: { [weak self] sleeperMatchups in
			   guard let self = self else { return }

			   if sleeperMatchups.isEmpty {
				  self.errorMessage = "Sorry, no matchups available\nfor \(self.leagueName) in Week \(week)."
				  self.currentManagerLeagues.removeAll { $0.id == self.leagueID }
				  self.isLoading = false
				  return
			   }

			   self.processSleeperMatchups(sleeperMatchups)
			})
			.store(in: &self.cancellables)
	  }
   }





   func getPlayerScore(for player: FantasyScores.FantasyModel.Team.PlayerEntry, week: Int) -> Double {
	  if leagueID == AppConstants.ESPNLeagueID[1] {
		 return player.playerPoolEntry.player.stats.first { $0.scoringPeriodId == week && $0.statSourceId == 0 }?.appliedTotal ?? 0.0
	  } else {
		 let playerId = String(player.playerPoolEntry.player.id)
		 return calculateSleeperPlayerScore(playerId: playerId)
	  }
   }

   // Add function to calculate Sleeper player scores
   func calculateSleeperPlayerScore(playerId: String) -> Double {
	  // Use the weeklyStats and sleeperLeagueSettings to calculate the score
	  guard let playerStats = playerStats[playerId],
			let scoringSettings = sleeperLeagueSettings else {
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


   func createPlayerEntry(from playerId: String) -> FantasyScores.FantasyModel.Team.PlayerEntry {
	  // Get player details from PlayerViewModel
	  if let player = playerViewModel.players.first(where: { $0.id == playerId }) {
		 let fullName = "\(player.firstName ?? "") \(player.lastName ?? "")"
		 let position = player.position ?? "FLEX"
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
	  } else {
		 print("DP - Warning: Player not found for ID \(playerId). Creating default entry.")
		 return createDefaultPlayerEntry(playerId: playerId)
	  }
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

   private func calculateESPNTeamScore(team: FantasyScores.FantasyModel.Team?, week: Int) -> Double {
	  guard let team = team else { return 0.0 }
	  return team.roster?.entries.reduce(0.0) { sum, entry in
		 sum + (entry.playerPoolEntry.player.stats.first {
			$0.scoringPeriodId == week && $0.statSourceId == 0
		 }?.appliedTotal ?? 0.0)
	  } ?? 0.0
   }

   func updateSelectedManager(_ managerID: String) {
	  self.selectedManagerID = managerID
	  updateLeagueName()
   }

   func fetchSleeperLeagues(forUserID userID: String) async {
	  guard let url = URL(string: "https://api.sleeper.app/v1/user/\(userID)/leagues/nfl/\(selectedYear)") else {
		 print("DP - Invalid Sleeper leagues URL")
		 return
	  }

	  do {
		 let (data, _) = try await URLSession.shared.data(from: url)
		 let leagues = try JSONDecoder().decode([FantasyScores.SleeperLeagueResponse].self, from: data)

		 let sleeperLeagues = leagues.map {
			FantasyScores.AnyLeagueResponse(id: $0.leagueID, name: $0.name, type: .sleeper)
		 }

		 DispatchQueue.main.async {
			self.currentManagerLeagues.append(contentsOf: sleeperLeagues)
			self.sleeperLeagues = leagues
			print("DP - Successfully fetched \(sleeperLeagues.count) Sleeper leagues")
		 }
	  } catch {
		 print("DP - Error decoding Sleeper leagues: \(error)")
	  }
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
			let _ = JSONDecoder()
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
			   self?.playerStats = statsData
			   print("Weekly stats fetched for \(statsData.count) players")
			   self?.objectWillChange.send()
			}
		 } catch {
			print("Error decoding weekly stats: \(error)")
		 }
	  }.resume()
   }


   private func getSleeperAvatarURL(userID: String) -> URL? {
	  if let avatarID = userAvatars[userID] {
		 return URL(string: "https://sleepercdn.com/avatars/\(avatarID)")
	  }
	  // Fetch avatar if not cached
	  fetchSleeperUser(userID: userID)
	  return nil
   }

   private func calculateSleeperTeamScore(matchup: FantasyScores.SleeperMatchup) -> Double {
	  guard let starters = matchup.starters else { return 0.0 }

	  return starters.reduce(0.0) { total, playerId in
		 if let playerStats = weeklyStats[playerId] {
			var playerScore = 0.0
			for (statKey, statValue) in playerStats {
			   if let scoring = sleeperLeagueSettings?[statKey] as? Double {
				  playerScore += statValue * scoring
			   }
			}
			return total + playerScore
		 }
		 return total
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
			completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
			return
		 }

		 do {
			let rosters = try JSONDecoder().decode([SleeperRoster].self, from: data)
			completion(.success(rosters))
		 } catch {
			print("DP - Error decoding rosters: \(error)")
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

   // MARK: This is where it all starts
   func fetchESPNManagerLeagues(forUserID userID: String) {
	  isLoading = true
	  print("DP - Fetching manager leagues for userID: \(userID)")

	  // Fetch both ESPN and Sleeper leagues
	  Task {
		 do {
			// Fetch ESPN leagues
			guard let url = URL(string: "https://fan.api.espn.com/apis/v2/fans/\(userID)?configuration=SITE_DEFAULT&displayEvents=true&displayNow=true&displayRecs=true&displayHiddenPrefs=true&featureFlags=expandAthlete&featureFlags=isolateEvents&featureFlags=challengeEntries&platform=web&recLimit=5&coreData=logos&showAirings=buy%2Clive%2Creplay&authorizedNetworks=espn3&entitlements=ESPN_PLUS&zipcode=23607") else {
			   print("DP - Invalid ESPN URL.")
			   return
			}

			var request = URLRequest(url: url)
			request.httpMethod = "GET"
			request.addValue("application/json", forHTTPHeaderField: "Accept")
			request.addValue("SWID=\(AppConstants.SWID); espn_s2=\(AppConstants.ESPN_S2)", forHTTPHeaderField: "Cookie")

			print("DP - Sending request to ESPN API")
			let (responseData, response) = try await URLSession.shared.data(for: request)
			print("DP - Received response from ESPN API")

			// Check for HTTP status code
			if let httpResponse = response as? HTTPURLResponse {
			   print("DP - HTTP Status Code: \(httpResponse.statusCode)")
			   if httpResponse.statusCode != 200 {
				  print("DP - Error: Unexpected HTTP status code")
				  return
			   }
			}

			// Parse ESPN leagues
			let espnLeagues = parseESPNLeagues(from: responseData)
			print("DP - Parsed \(espnLeagues.count) ESPN leagues")

			// Fetch Sleeper leagues
			await fetchSleeperLeagues(forUserID: AppConstants.GpSleeperID)

			DispatchQueue.main.async {
			   // Combine ESPN and Sleeper leagues
			   let newESPNLeagues = espnLeagues.map {
				  FantasyScores.AnyLeagueResponse(
					 id: $0.id,
					 name: "\($0.teamName)", // - \($0.name)",
					 //					 name: "\($0.teamName) - \($0.name)",
					 type: .espn
				  )
			   }
			   // After fetching ESPN and Sleeper leagues and combining them
			   self.currentManagerLeagues += newESPNLeagues
			   print("DP - Added \(newESPNLeagues.count) ESPN leagues to currentManagerLeagues")
			   self.objectWillChange.send()
			   self.isLoading = false
			   print("DP - Total Leagues in currentManagerLeagues: \(self.currentManagerLeagues.count)")
			   self.debugPrintLeagues()

			   // If you haven't already done so, save them:
			   self.originalManagerLeagues = self.currentManagerLeagues
			   print("DP - Added \(newESPNLeagues.count) ESPN leagues to currentManagerLeagues")
			   self.objectWillChange.send()
			   self.isLoading = false
			   print("DP - Total Leagues in currentManagerLeagues: \(self.currentManagerLeagues.count)")
			   self.debugPrintLeagues()

			   // Fetch fantasy data for the first league if available
			   if let firstLeague = self.currentManagerLeagues.first {
				  self.leagueID = firstLeague.id
				  self.fetchFantasyMatchupViewModelMatchups()
			   }
			}
		 } catch {
			print("DP - Error fetching leagues: \(error)")
			DispatchQueue.main.async {
			   self.isLoading = false
			}
		 }
	  }
   }

   func parseESPNLeagues(from data: Data) -> [FantasyScores.ESPNLeagueResponse] {
	  var leagues: [FantasyScores.ESPNLeagueResponse] = []
	  do {
		 print("DP - Starting to parse ESPN leagues")
		 if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
			print("DP - JSON parsed successfully")
			if let preferences = json["preferences"] as? [[String: Any]] {
			   print("DP - Found \(preferences.count) preferences")
			   for preference in preferences {
				  if let metaData = preference["metaData"] as? [String: Any],
					 let entry = metaData["entry"] as? [String: Any],
					 let entryId = entry["entryId"] as? Int,
					 let entryMetadata = entry["entryMetadata"] as? [String: Any],
					 let teamName = entryMetadata["teamName"] as? String,
					 let groups = entry["groups"] as? [[String: Any]] {
					 print("DP - Processing league with ID: \(entryId)")
					 for group in groups {
						if let groupId = group["groupId"] as? Int,
						   let _groupName = group["groupName"] as? String {
						   let league = FantasyScores.ESPNLeagueResponse(
							  id: String(groupId),
							  name: teamName, // Use teamName instead of groupName
							  teamName: teamName
						   )
						   leagues.append(league)
						   print("DP - Added league: \(teamName)")
						}
					 }
				  }
			   }
			} else {
			   print("DP - No preferences found in JSON")
			}
		 } else {
			print("DP - Failed to parse JSON")
		 }
	  } catch {
		 print("DP - Error parsing ESPN leagues JSON: \(error)")
	  }
	  print("DP - Parsed \(leagues.count) ESPN leagues")
	  return leagues
   }

   func FetchManagerLeagues(from jsonData: Data) -> [Int: Int] {
	  var leagueTeamMapping: [Int: Int] = [:]
	  do {
		 if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
			let preferences = json["preferences"] as? [[String: Any]] {
			for preference in preferences {
			   if let metaData = preference["metaData"] as? [String: Any],
				  let entry = metaData["entry"] as? [String: Any],
				  let entryId = entry["entryId"] as? Int,
				  let groups = entry["groups"] as? [[String: Any]] {
				  for group in groups {
					 if let groupId = group["groupId"] as? Int {
						leagueTeamMapping[groupId] = entryId
					 }
				  }
			   }
			}
		 }
	  } catch {
		 print("DP - Error parsing ESPN leagues JSON: \(error)")
	  }
	  return leagueTeamMapping
   }

   func updateCurrentManagerLeagues() {
	  // Combine ESPN and Sleeper leagues
	  let allLeagues = espnLeagues.map { FantasyScores.AnyLeagueResponse(id: String($0.id), name: $0.name, type: .espn) } +
	  sleeperLeagues.map { FantasyScores.AnyLeagueResponse(id: $0.leagueID, name: $0.name, type: .sleeper) }

	  // Update currentManagerLeagues
	  currentManagerLeagues = allLeagues

	  // Add debug print
	  print("Current Manager Leagues updated: \(currentManagerLeagues)")
   }

   func updateLeagueName() {
	  if leagueID == AppConstants.ESPNLeagueID[1] {
		 leagueName = "ESPN League"
	  } else if let league = currentManagerLeagues.first(where: { $0.id == leagueID }) {
		 leagueName = league.name
	  } else {
		 leagueName = "Fantasy Football"
	  }
   }

   // Add this method to debug the currentManagerLeagues
   func debugPrintLeagues() {
	  print("DP - Debug printing all leagues:")
	  for (index, league) in currentManagerLeagues.enumerated() {
		 print("DP - League \(index + 1): ID = \(league.id), Name = \(league.name)")
	  }
   }

   // fetch the all of the ESPN leagues for a manager
   func FetchManagerLeagues(forUserID userID: String) {
	  isLoading = true
	  print("DP - Fetching ESPN manager leagues for userID: \(userID)")

	  // Construct the URL
	  guard let url = URL(string: "https://fan.api.espn.com/apis/v2/fans/\(userID)?configuration=SITE_DEFAULT&displayEvents=true&displayNow=true&displayRecs=true&displayHiddenPrefs=true&featureFlags=expandAthlete&featureFlags=isolateEvents&featureFlags=challengeEntries&platform=web&recLimit=5&coreData=logos&showAirings=buy%2Clive%2Creplay&authorizedNetworks=espn3&entitlements=ESPN_PLUS&zipcode=23607") else {
		 print("DP - Invalid ESPN URL.")
		 return
	  }

	  var request = URLRequest(url: url)
	  request.httpMethod = "GET"
	  request.addValue("application/json", forHTTPHeaderField: "Accept")
	  request.addValue("SWID=\(AppConstants.SWID); espn_s2=\(AppConstants.ESPN_S2)", forHTTPHeaderField: "Cookie")

	  // Perform the network request
	  URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
		 guard let self = self else { return }

		 if let error = error {
			print("DP - Error fetching ESPN leagues: \(error)")
			self.isLoading = false
			return
		 }

		 guard let data = data else {
			print("DP - No data received from ESPN leagues API.")
			self.isLoading = false
			return
		 }

		 // Parse the data to extract leagueID and teamID
		 let leagueTeamMapping = self.FetchManagerLeagues(from: data)

		 // Debug print the fetched leagues
		 print("DP - Fetched ESPN Leagues:")
		 for (leagueID, teamID) in leagueTeamMapping {
			print("DP - League ID: \(leagueID), Team ID: \(teamID)")
		 }

		 // Map leagueID and teamID to currentManagerLeagues
		 // Remove the FantasyScores.SleeperLeagueResponse initializer
		 let espnLeagues = leagueTeamMapping.map { FantasyScores.AnyLeagueResponse(id: String($0.key), name: "ESPN League \($0.key)", type: .espn) }

		 DispatchQueue.main.async {
			// Remove the additional mapping and directly append espnLeagues
			self.currentManagerLeagues += espnLeagues
			self.objectWillChange.send()
			print("DP - Total Leagues in currentManagerLeagues: \(self.currentManagerLeagues.count)")
			self.isLoading = false
		 }
	  }.resume()
   }

   func fetchNFLRosterData() {
	  nflRosterViewModel.fetchPlayersForAllTeams {}
   }
}
