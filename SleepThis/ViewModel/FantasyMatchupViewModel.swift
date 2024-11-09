import SwiftUI
import Combine

class FantasyMatchupViewModel: ObservableObject {
   @Published var fantasyModel: FantasyScores.FantasyModel?
   @Published var matchups: [AnyFantasyMatchup] = []
   @Published var isLoading: Bool = false
   @Published var errorMessage: String? = nil
   @Published var leagueID: String = AppConstants.ESPNLeagueID
   @Published var sleeperLeagues: [FantasyScores.SleeperLeagueResponse] = []
   @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
   @Published var selectedWeek: Int = {
	  let firstWeek = 37
	  let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
	  let offset = currentWeek >= firstWeek ? currentWeek - firstWeek + 1 : 0
	  return min(max(1, offset), 17)
   }()
   var sleeperScoringSettings: [String: Double] = [:]
   var sleeperPlayers: [String: FantasyScores.SleeperPlayer] = [:]

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
		 fetchFantasyData(forWeek: selectedWeek)
	  } else {
		 fetchSleeperLeagueSettings()
	  }
   }

   func getRoster(for matchup: AnyFantasyMatchup, teamIndex: Int, isBench: Bool) -> [FantasyScores.FantasyModel.Team.PlayerEntry] {
	  let teamId = teamIndex == 0 ? matchup.awayTeamID : matchup.homeTeamID
	  guard let team = fantasyModel?.teams.first(where: { $0.id == teamId }) else { return [] }

	  let activeSlots: [Int] = [0, 2, 3, 4, 5, 6, 16, 17, 23] // Standard active slots
	  let benchSlots: [Int] = Array(20...30) // Typical ESPN bench slots range

	  let relevantSlots = isBench ? benchSlots : activeSlots
	  let slotOrder = Dictionary(uniqueKeysWithValues: relevantSlots.enumerated().map { ($1, $0) })

	  return team.roster?.entries
		 .filter { player in
			relevantSlots.contains(player.lineupSlotId)
		 }
		 .sorted {
			let order1 = slotOrder[$0.lineupSlotId] ?? Int.max
			let order2 = slotOrder[$1.lineupSlotId] ?? Int.max
			return order1 < order2
		 } ?? []
   }



   func getPlayerScore(for player: FantasyScores.FantasyModel.Team.PlayerEntry, week: Int) -> Double {
	  return player.playerPoolEntry.player.stats.first(where: { $0.scoringPeriodId == week && $0.statSourceId == 0 })?.appliedTotal ?? 0.0
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

			var processedMatchups: [AnyFantasyMatchup] = []

			for matchup in model.schedule.filter({ $0.matchupPeriodId == self.selectedWeek }) {
			   let homeTeamId = matchup.home.teamId
			   let awayTeamId = matchup.away.teamId

			   let homeTeam = model.teams.first { $0.id == homeTeamId }
			   let awayTeam = model.teams.first { $0.id == awayTeamId }

			   let homeTeamName = homeTeam?.name ?? "Unknown"
			   let awayTeamName = awayTeam?.name ?? "Unknown"

			   // Calculate Home Team Active Score
			   let homeTeamScore = homeTeam?.roster?.entries.reduce(0.0) {
				  $0 + self.getPlayerScore(for: $1, week: self.selectedWeek)
			   } ?? 0.0

			   // Calculate Away Team Active Score
			   let awayTeamScore = awayTeam?.roster?.entries.reduce(0.0) {
				  $0 + self.getPlayerScore(for: $1, week: self.selectedWeek)
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
			self.isLoading = false
		 })
		 .store(in: &cancellables)
   }

   func fetchFantasyMatchupViewModelSleeperLeagues(forUserID userID: String) {
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

   func fetchSleeperLeagueSettings() {
	  guard let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)") else { return }

	  URLSession.shared.dataTaskPublisher(for: url)
		 .map { $0.data }
		 .decode(type: FantasyScores.SleeperLeagueSettings.self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { [weak self] completion in
			if case .failure(let error) = completion {
			   self?.errorMessage = "Error fetching Sleeper league settings: \(error.localizedDescription)"
			}
		 }, receiveValue: { [weak self] settings in
			self?.sleeperScoringSettings = settings.scoringSettings
			self?.fetchSleeperPlayers()
		 })
		 .store(in: &cancellables)
   }

   func fetchSleeperPlayers() {
	  guard let url = URL(string: "https://api.sleeper.app/v1/players/nfl") else { return }

	  URLSession.shared.dataTaskPublisher(for: url)
		 .map { $0.data }
		 .decode(type: [String: FantasyScores.SleeperPlayer].self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { [weak self] completion in
			if case .failure(let error) = completion {
			   self?.errorMessage = "Error fetching Sleeper players: \(error.localizedDescription)"
			}
		 }, receiveValue: { [weak self] players in
			self?.sleeperPlayers = players
			self?.fetchFantasyMatchupViewModelSleeperMatchups()
		 })
		 .store(in: &cancellables)
   }

   func fetchFantasyMatchupViewModelSleeperMatchups() {
	  guard leagueID != AppConstants.ESPNLeagueID else { return }

	  let week = selectedWeek
	  guard let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)/matchups/\(week)") else { return }

	  URLSession.shared.dataTaskPublisher(for: url)
		 .map { response -> Data in
			return response.data
		 }
		 .decode(type: [FantasyScores.SleeperMatchup].self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { [weak self] completion in
			self?.isLoading = false
			if case .failure(let error) = completion {
			   self?.errorMessage = "Error fetching Sleeper data: \(error.localizedDescription)"
			}
		 }, receiveValue: { [weak self] sleeperMatchups in
			guard let self = self else { return }
			self.processSleeperMatchups(sleeperMatchups)
		 })
		 .store(in: &cancellables)
   }

   func processSleeperMatchups(_ sleeperMatchups: [FantasyScores.SleeperMatchup]) {
	  let groupedMatchups = Dictionary(grouping: sleeperMatchups, by: { $0.matchup_id })
	  var processedMatchups: [AnyFantasyMatchup] = []

	  for (_, matchups) in groupedMatchups where matchups.count == 2 {
		 let team1 = matchups[0]
		 let team2 = matchups[1]

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

		 let anyMatchup = AnyFantasyMatchup(fantasyMatchup, sleeperData: (team1, team2))
		 processedMatchups.append(anyMatchup)
	  }

	  self.matchups = processedMatchups
   }

   func calculatePlayerScore(playerID: String) -> Double {
	  guard let player = sleeperPlayers[playerID],
			let yearStats = player.stats?[String(selectedYear)],
			let weekStats = yearStats[String(selectedWeek)] else { return 0.0 }

	  var totalScore = 0.0
	  for (statKey, statValue) in weekStats {
		 let scoringModifier = sleeperScoringSettings[statKey] ?? 0.0
		 totalScore += statValue * scoringModifier
	  }

	  return totalScore
   }

   func getScore(for matchup: AnyFantasyMatchup, teamIndex: Int) -> Double {
	  return matchup.scores[teamIndex]
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
		 default: return ""
	  }
   }
}
