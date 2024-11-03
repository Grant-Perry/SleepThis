import SwiftUI
import Combine

class FantasyMatchupViewModel: ObservableObject {
   struct SleeperLeague: Identifiable {
	  var id: String { leagueID }
	  let leagueID: String
	  let name: String
   }

   @Published var espnFantasyModel: ESPNFantasy.ESPNFantasyModel?
   @Published var matchups: [AnyFantasyMatchup] = []
   @Published var isLoading: Bool = false
   @Published var errorMessage: String? = nil
   @Published var leagueID: String = AppConstants.ESPNLeagueID
   @Published var sleeperLeagues: [SleeperLeague] = []
   @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
   @Published var selectedWeek: Int = {
	  let firstWeek = 36
	  let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
	  let offset = currentWeek >= firstWeek ? currentWeek - firstWeek + 1 : 0
	  return min(max(1, offset), 17)
   }()

   private var cancellables = Set<AnyCancellable>()
   private var timer: Timer?

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
		 .decode(type: ESPNFantasy.ESPNFantasyModel.self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink(receiveCompletion: { [weak self] completion in
			self?.isLoading = false
			if case .failure(let error) = completion {
			   print("Error fetching ESPN data: \(error)")
			   self?.errorMessage = "Error fetching ESPN data: \(error.localizedDescription)"
			}
		 }, receiveValue: { [weak self] model in
			print("Successfully fetched ESPN data")
			self?.espnFantasyModel = model
			self?.processMatchups(model: model)
			self?.isLoading = false
		 })
		 .store(in: &cancellables)
   }

   private func processMatchups(model: ESPNFantasy.ESPNFantasyModel) {
	  matchups = model.schedule.filter { $0.matchupPeriodId == selectedWeek }.map { matchup in
		 let homeTeam = model.teams.first { $0.id == matchup.home.teamId }
		 let awayTeam = model.teams.first { $0.id == matchup.away.teamId }
		 let homeScore = calculateScore(for: homeTeam)
		 let awayScore = calculateScore(for: awayTeam)
		 return AnyFantasyMatchup(ESPNFantasyMatchup(
			homeTeamName: homeTeam?.name ?? "Unknown",
			awayTeamName: awayTeam?.name ?? "Unknown",
			homeScore: homeScore,
			awayScore: awayScore,
			homeManagerName: homeTeam?.name ?? "Unknown",
			awayManagerName: awayTeam?.name ?? "Unknown"
		 ))
	  }
   }

   private func calculateScore(for team: ESPNFantasy.ESPNFantasyModel.Team?) -> Double {
	  team?.roster?.entries
		 .filter { $0.lineupSlotId < 20 || $0.lineupSlotId == 23 }
		 .reduce(0.0) { $0 + ($1.playerPoolEntry.player.stats.first { $0.scoringPeriodId == selectedWeek && $0.statSourceId == 0 }?.appliedTotal ?? 0) }
	  ?? 0.0
   }

   func fetchFantasyMatchupViewModelSleeperLeagues(forUserID userID: String) {
	  if let url = URL(string: "https://api.sleeper.app/v1/user/\(userID)/leagues/nfl/\(selectedYear)") {
		 URLSession.shared.dataTaskPublisher(for: url)
			.map { $0.data }
			.decode(type: [SleeperLeagueResponse].self, decoder: JSONDecoder())
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
			   if case .failure(let error) = completion {
				  print("Error fetching Sleeper leagues: \(error)")
				  self?.errorMessage = "Error fetching Sleeper leagues: \(error.localizedDescription)"
			   }
			}, receiveValue: { [weak self] leagues in
			   print("Successfully fetched Sleeper leagues")
			   self?.sleeperLeagues = leagues.map { SleeperLeague(leagueID: $0.leagueID, name: $0.name) }
			   if let firstLeague = self?.sleeperLeagues.first {
				  self?.leagueID = firstLeague.leagueID
				  self?.fetchFantasyMatchupViewModelMatchups()
			   }
			})
			.store(in: &cancellables)
	  }
   }

   func setupRefreshTimer(with interval: Int) {
	  timer?.invalidate()
	  guard interval > 0 else { return }
	  timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true) { [weak self] _ in
		 self?.fetchFantasyMatchupViewModelMatchups()
	  }
   }

   private func fetchFantasyMatchupViewModelSleeperMatchups() {
	  guard leagueID != AppConstants.ESPNLeagueID else { return }
	  let week = selectedWeek

	  if let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)/matchups/\(week)") {
		 isLoading = true
		 errorMessage = nil

		 URLSession.shared.dataTaskPublisher(for: url)
			.map { response -> Data in
			   return response.data
			}
			.decode(type: [SleeperMatchup].self, decoder: JSONDecoder())
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
			   self?.isLoading = false
			   if case .failure(let error) = completion {
				  self?.errorMessage = "Error fetching Sleeper data: \(error.localizedDescription)"
			   }
			}, receiveValue: { [weak self] sleeperMatchups in
			   guard let self = self else { return }

			   // Group matchups by `matchup_id` to form pairs of teams in each matchup
			   let groupedMatchups = Dictionary(grouping: sleeperMatchups, by: { $0.matchup_id })
			   var processedMatchups: [AnyFantasyMatchup] = []

			   for (_, matchups) in groupedMatchups {
				  if matchups.count == 2 {
					 let team1 = matchups[0]
					 let team2 = matchups[1]

					 // Create a new `ESPNFantasyMatchup` instance and use `AnyFantasyMatchup` to encapsulate it
					 let fantasyMatchup = ESPNFantasyMatchup(
						homeTeamName: "Team \(team1.roster_id)",
						awayTeamName: "Team \(team2.roster_id)",
						homeScore: team1.points,
						awayScore: team2.points,
						homeAvatarURL: nil,
						awayAvatarURL: nil,
						homeManagerName: "Manager \(team1.roster_id)",
						awayManagerName: "Manager \(team2.roster_id)"
					 )

					 processedMatchups.append(AnyFantasyMatchup(fantasyMatchup))
				  }
			   }

			   self.matchups = processedMatchups
			})
			.store(in: &cancellables)
	  }
   }


   func getScore(for matchup: AnyFantasyMatchup, teamIndex: Int) -> Double {
	  return matchup.scores[teamIndex]
   }

   func getManagerName(for matchup: AnyFantasyMatchup, teamIndex: Int) -> String {
	  return teamIndex < matchup.managerNames.count ? matchup.managerNames[teamIndex] : "Unknown"
   }
}
