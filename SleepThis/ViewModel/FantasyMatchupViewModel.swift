import SwiftUI
import Combine

class FantasyMatchupViewModel: ObservableObject {
   @Published var fantasyModel: FantasyScores.FantasyModel?
   @Published var matchups: [AnyFantasyMatchup] = []
   @Published var isLoading: Bool = false
   @Published var errorMessage: String? = nil
   @Published var leagueID: String = AppConstants.ESPNLeagueID
   @Published var sleeperLeagues: [FantasyScores.SleeperLeagueResponse] = []
   @Published var scoringSettings: SleeperScoring.ScoringSettings = SleeperScoring.ScoringSettings.defaultSettings()
   @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
   @Published var selectedWeek: Int = {
	  let firstWeek = 37
	  let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
	  let offset = currentWeek >= firstWeek ? currentWeek - firstWeek + 1 : 0
	  return min(max(1, offset), 17)
   }()

   private var cancellables = Set<AnyCancellable>()
   private var refreshTimer: AnyCancellable?

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
	  isLoading = true
	  errorMessage = nil
	  matchups.removeAll()

	  if leagueID == AppConstants.ESPNLeagueID {
		 fetchESPNMatchups(forWeek: selectedWeek)
	  } else {
		 fetchSleeperScoringSettings { [weak self] in
			self?.fetchSleeperMatchups()
		 }
	  }
   }

   func getScore(for matchup: AnyFantasyMatchup, teamIndex: Int) -> Double {
	  let teamID = teamIndex == 0 ? matchup.awayTeamID : matchup.homeTeamID
	  guard let team = fantasyModel?.teams.first(where: { $0.id == teamID }) else { return 0.0 }

	  // Sum up the score for each player in the roster entries for the given week
	  return team.roster?.entries.reduce(0.0) { total, entry in
		 total + getPlayerScore(for: entry, week: selectedWeek, scoringSettings: scoringSettings)
	  } ?? 0.0
   }


   func saveJSONToDownloads(data: Data) {
	  let downloadsPath = URL(fileURLWithPath: "/Users/gp./Downloads/response.json")

	  do {
		 try data.write(to: downloadsPath)
		 print("JSON response saved to: \(downloadsPath.path)")
	  } catch {
		 print("Failed to write JSON to file: \(error)")
	  }
   }


   func fetchSleeperScoringSettings(completion: @escaping () -> Void) {
	  guard let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)") else { return }

	  URLSession.shared.dataTask(with: url) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
		 guard let data = data else {
			print("Failed to fetch scoring settings: \(error?.localizedDescription ?? "Unknown error")")
			return
		 }

		 do {
			// Isolate the decoding to capture errors
			let decodedLeagueInfo: SleeperScoring.SleeperLeagueInfo = try JSONDecoder().decode(SleeperScoring.SleeperLeagueInfo.self, from: data)

			// Separate DispatchQueue block
			DispatchQueue.main.async { [weak self] in
			   guard let strongSelf = self else { return }
			   strongSelf.scoringSettings = decodedLeagueInfo.scoringSettings
			   completion()
			}
		 } catch {
			print("Error decoding scoring settings: \(error)")
		 }
	  }.resume()
   }

   func fetchESPNMatchups(forWeek week: Int) {
	  print("[fetchESPNMatchups:] Starting ESPN matchup fetch for week \(week)")

	  guard leagueID == AppConstants.ESPNLeagueID,
			let url = URL(string: "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/\(selectedYear)/segments/0/leagues/\(leagueID)?view=mMatchupScore&view=mLiveScoring&view=mRoster&scoringPeriodId=\(week)") else {
		 print("[fetchESPNMatchups:] Invalid league ID or URL for ESPN data fetch.")
		 isLoading = false
		 return
	  }

	  print("[fetchESPNMatchups:] URL constructed: \(url)")

	  var request = URLRequest(url: url)
	  request.addValue("application/json", forHTTPHeaderField: "Accept")
	  request.addValue("SWID=\(AppConstants.SWID); espn_s2=\(AppConstants.ESPN_S2)", forHTTPHeaderField: "Cookie")

	  URLSession.shared.dataTaskPublisher(for: request)
		 .map { response -> Data in
			let statusCode = (response.response as? HTTPURLResponse)?.statusCode ?? 0
			print("[fetchESPNMatchups:] Response received. Status code: \(statusCode)")
			if let responseString = String(data: response.data, encoding: .utf8) {
			   print("[fetchESPNMatchups:] Response data: \(responseString.prefix(1000))...") // Display the first 1000 characters of JSON
			} else {
			   print("[fetchESPNMatchups:] Unable to convert response data to string.")
			}
			return response.data
		 }
		 .decode(type: FantasyScores.FantasyModel.self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { [weak self] completion in
			self?.isLoading = false
			switch completion {
			   case .failure(let error):
				  print("[fetchESPNMatchups:] Error decoding ESPN data: \(error)")
				  self?.errorMessage = "Error fetching ESPN data: \(error.localizedDescription)"
			   case .finished:
				  print("[fetchESPNMatchups:] Successfully completed data fetch.")
			}
		 }, receiveValue: { [weak self] model in
			print("[fetchESPNMatchups:] Successfully decoded model. Processing matchups.")
			print("[fetchESPNMatchups:] Number of teams: \(model.teams.count), Number of matchups: \(model.schedule.count)")
			model.teams.forEach { team in
			   print("[fetchESPNMatchups:] Team ID: \(team.id), Team Name: \(team.name)")
			}
			self?.fantasyModel = model
			self?.processMatchups(model)
		 })
		 .store(in: &cancellables)
   }

   func fetchSleeperMatchups() {
	  print("[fetchSleeperMatchups:] Starting fetch for Sleeper matchups for league \(leagueID) and week \(selectedWeek)")

	  guard leagueID != AppConstants.ESPNLeagueID else {
		 print("[fetchSleeperMatchups:] Skipping fetch as league ID matches ESPNLeagueID.")
		 return
	  }

	  let week = selectedWeek
	  guard let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)/matchups/\(week)") else {
		 print("[fetchSleeperMatchups:] Invalid URL constructed.")
		 return
	  }

	  print("[fetchSleeperMatchups:] URL constructed: \(url)")

	  URLSession.shared.dataTaskPublisher(for: url)
		 .map { response -> Data in
			print("[fetchSleeperMatchups:] Response received. Status code: \((response.response as? HTTPURLResponse)?.statusCode ?? 0)")
			return response.data
		 }
		 .decode(type: [FantasyScores.SleeperMatchup].self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { [weak self] completion in
			self?.isLoading = false
			if case .failure(let error) = completion {
			   print("[fetchSleeperMatchups:] Error fetching Sleeper data: \(error)")
			   self?.errorMessage = "Error fetching Sleeper data: \(error.localizedDescription)"
			} else {
			   print("[fetchSleeperMatchups:] Successfully completed data fetch.")
			}
		 }, receiveValue: { [weak self] sleeperMatchups in
			guard let self = self else { return }
			print("[fetchSleeperMatchups:] Successfully decoded Sleeper matchups. Number of entries: \(sleeperMatchups.count)")

			let groupedMatchups = Dictionary(grouping: sleeperMatchups, by: { $0.matchup_id })
			var processedMatchups: [AnyFantasyMatchup] = []

			for (matchupID, matchups) in groupedMatchups where matchups.count == 2 {
			   let team1 = matchups[0]
			   let team2 = matchups[1]

			   print("[fetchSleeperMatchups:] Processing matchup \(matchupID) between Team \(team1.roster_id) and Team \(team2.roster_id)")

			   let fantasyMatchup = FantasyScores.FantasyMatchup(
				  homeTeamName: "Team \(team1.roster_id)",
				  awayTeamName: "Team \(team2.roster_id)",
				  homeScore: team1.points,
				  awayScore: team2.points,
				  homeAvatarURL: nil,
				  awayAvatarURL: nil,
				  homeManagerName: "Manager \(team1.roster_id)",
				  awayManagerName: "Manager \(team2.roster_id)",
				  homeTeamID: team1.roster_id,
				  awayTeamID: team2.roster_id
			   )

			   processedMatchups.append(AnyFantasyMatchup(fantasyMatchup))
			}

			print("[fetchSleeperMatchups:] Total processed matchups: \(processedMatchups.count)")
			self.matchups = processedMatchups
		 })
		 .store(in: &cancellables)
   }


   func getPlayerScore(for player: FantasyScores.FantasyModel.Team.PlayerEntry, week: Int, scoringSettings: SleeperScoring.ScoringSettings) -> Double {
	  let stats = player.playerPoolEntry.player.stats.first { $0.scoringPeriodId == week && $0.statSourceId == 0 }
	  guard let stats = stats else {
		 print("[getPlayerScore:] No stats found for player \(player.playerPoolEntry.player.fullName) in week \(week)")
		 return 0.0
	  }

	  let passingPoints = ((stats.passYards ?? 0) / 25.0 * scoringSettings.passYards) +
	  ((stats.passTouchdowns ?? 0) * scoringSettings.passTouchdowns) -
	  ((stats.passInterceptions ?? 0) * scoringSettings.passInterceptions)

	  let rushingPoints = ((stats.rushYards ?? 0) / 10.0 * scoringSettings.rushYards) +
	  ((stats.rushTouchdowns ?? 0) * scoringSettings.rushTouchdowns)

	  let receivingPoints = ((stats.receivingYards ?? 0) / 10.0 * scoringSettings.receivingYards) +
	  ((stats.receivingTouchdowns ?? 0) * scoringSettings.receivingTouchdowns)

	  let fumblePoints = (stats.fumblesLost ?? 0) * scoringSettings.fumblesLost

	  let totalScore = passingPoints + rushingPoints + receivingPoints + fumblePoints
	  print("[getPlayerScore:] Calculated score for player \(player.playerPoolEntry.player.fullName): \(totalScore) points")

	  return totalScore
   }


   func getOrderedRoster(for matchup: AnyFantasyMatchup, teamIndex: Int, isBench: Bool, scoringSettings: SleeperScoring.ScoringSettings) -> [FantasyScores.FantasyModel.Team.PlayerEntry] {
	  let teamId = teamIndex == 0 ? matchup.awayTeamID : matchup.homeTeamID
	  guard let team = fantasyModel?.teams.first(where: { $0.id == teamId }) else { return [] }

	  let roster = team.roster?.entries.filter { player in
		 isBench ? player.lineupSlotId >= 20 && player.lineupSlotId != 23 : player.lineupSlotId < 20 || player.lineupSlotId == 23
	  } ?? []

	  let orderedPositions = ["QB", "RB", "RB", "WR", "WR", "TE", "FLEX", "D/ST", "K"]
	  return roster.sorted {
		 let pos1 = $0.playerPoolEntry.player.position ?? ""
		 let pos2 = $1.playerPoolEntry.player.position ?? ""
		 let index1 = orderedPositions.firstIndex(of: pos1) ?? Int.max
		 let index2 = orderedPositions.firstIndex(of: pos2) ?? Int.max
		 return index1 < index2
	  }
   }

   func fetchSleeperLeagues(forUserID userID: String) {
	  guard let url = URL(string: "https://api.sleeper.app/v1/user/\(userID)/leagues/nfl/\(selectedYear)") else {
		 print("[fetchSleeperLeagues:] Invalid URL.")
		 return
	  }

	  print("[fetchSleeperLeagues:] Fetching leagues for user ID \(userID) and year \(selectedYear) with URL: \(url)")

	  URLSession.shared.dataTaskPublisher(for: url)
		 .map { response -> Data in
			print("[fetchSleeperLeagues:] Response received. Status code: \((response.response as? HTTPURLResponse)?.statusCode ?? 0)")
			return response.data
		 }
		 .decode(type: [FantasyScores.SleeperLeagueResponse].self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { completion in
			if case .failure(let error) = completion {
			   print("[fetchSleeperLeagues:] Error fetching leagues: \(error)")
			   self.errorMessage = "Error fetching leagues."
			} else {
			   print("[fetchSleeperLeagues:] Completed fetching leagues successfully.")
			}
		 }, receiveValue: { leagues in
			print("[fetchSleeperLeagues:] Successfully decoded leagues. Number of leagues fetched: \(leagues.count)")
			leagues.forEach { print("[fetchSleeperLeagues:] League: \($0.name), League ID: \($0.leagueID)") }
			self.sleeperLeagues = leagues
		 })
		 .store(in: &cancellables)
   }


   private func processMatchups(_ model: FantasyScores.FantasyModel) {
	  var processedMatchups: [AnyFantasyMatchup] = []

	  for matchup in model.schedule.filter({ $0.matchupPeriodId == self.selectedWeek }) {
		 let homeTeamId = matchup.home.teamId
		 let awayTeamId = matchup.away.teamId
		 guard let homeTeam = model.teams.first(where: { $0.id == homeTeamId }),
			   let awayTeam = model.teams.first(where: { $0.id == awayTeamId }) else {
			continue
		 }

		 // Calculate scores using getScore method to ensure proper scoring logic
		 let homeTeamScore = homeTeam.roster?.entries.reduce(0.0) { $0 + getPlayerScore(for: $1, week: selectedWeek, scoringSettings: scoringSettings) } ?? 0.0
		 let awayTeamScore = awayTeam.roster?.entries.reduce(0.0) { $0 + getPlayerScore(for: $1, week: selectedWeek, scoringSettings: scoringSettings) } ?? 0.0

		 print("[processMatchups:] Home Team: \(homeTeam.name), Score: \(homeTeamScore)")
		 print("[processMatchups:] Away Team: \(awayTeam.name), Score: \(awayTeamScore)")

		 let fantasyMatchup = FantasyScores.FantasyMatchup(
			homeTeamName: homeTeam.name,
			awayTeamName: awayTeam.name,
			homeScore: homeTeamScore,
			awayScore: awayTeamScore,
			homeAvatarURL: nil,
			awayAvatarURL: nil,
			homeManagerName: homeTeam.name,
			awayManagerName: awayTeam.name,
			homeTeamID: homeTeamId,
			awayTeamID: awayTeamId
		 )

		 processedMatchups.append(AnyFantasyMatchup(fantasyMatchup))
	  }

	  // Update matchups and stop loading indicator
	  self.matchups = processedMatchups
	  self.isLoading = false
   }




}
