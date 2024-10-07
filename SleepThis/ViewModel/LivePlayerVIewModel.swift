import Foundation
import Combine

class LivePlayerViewModel: ObservableObject {
   @Published var players: [LivePlayerModel] = []
   private var cancellables = Set<AnyCancellable>()
   private let updateInterval: TimeInterval = 20
   private var timer: Timer?

   init() {
	  startUpdating()
   }

   func startUpdating() {
	  fetchESPNPlayerData()
	  timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
		 self?.fetchESPNPlayerData()
	  }
   }

   func fetchESPNPlayerData() {
	  guard let url = URL(string: "https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/2024/segments/0/leagues/\(AppConstants.LeagueID)?rosterForTeamId=7&view=mLiveScoring&view=mMatchupScore") else {
		 print("Invalid URL")
		 return
	  }

	  var request = URLRequest(url: url)
	  request.addValue("SWID=\(AppConstants.SWID)", forHTTPHeaderField: "Cookie")
	  request.addValue("ESPN_S2=\(AppConstants.ESPN_S2)", forHTTPHeaderField: "Cookie")

	  URLSession.shared.dataTaskPublisher(for: request)
		 .map(\.data)
		 .decode(type: LeagueResponse.self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .sink { completion in
			switch completion {
			   case .finished:
				  break
			   case .failure(let error):
				  print("Error fetching data: \(error)")
			}
		 } receiveValue: { [weak self] response in
			self?.players = response.rosterForCurrentScoringPeriod.entries
		 }
		 .store(in: &cancellables)
   }

   deinit {
	  timer?.invalidate()
   }
}

struct LeagueResponse: Codable {
   let rosterForCurrentScoringPeriod: RosterForCurrentScoringPeriod
}

struct RosterForCurrentScoringPeriod: Codable {
   let entries: [LivePlayerModel]
}

enum Position: Int, CaseIterable {
   case quarterback = 1
   case runningBack = 2
   case wideReceiver = 3
   case tightEnd = 4
   case kicker = 5
   case defenseST = 16

   var name: String {
	  switch self {
		 case .quarterback: return "Quarterback"
		 case .runningBack: return "Running Back"
		 case .wideReceiver: return "Wide Receiver"
		 case .tightEnd: return "Tight End"
		 case .kicker: return "Kicker"
		 case .defenseST: return "Defense/Special Teams"
	  }
   }
}

enum LineupSlot: Int, CaseIterable {
   case quarterback = 0
   case runningBack = 2
   case wideReceiver = 4
   case tightEnd = 6
   case defenseST = 16
   case kicker = 17
   case bench = 20
   case injuredReserve = 21
   case flex = 23

   var name: String {
	  switch self {
		 case .quarterback: return "Quarterback"
		 case .runningBack: return "Running Back"
		 case .wideReceiver: return "Wide Receiver"
		 case .tightEnd: return "Tight End"
		 case .defenseST: return "Defense/Special Teams"
		 case .kicker: return "Kicker"
		 case .bench: return "Bench"
		 case .injuredReserve: return "Injured Reserve"
		 case .flex: return "Flex"
	  }
   }
}

enum StatType: String, CaseIterable {
   case passAttempts = "0"
   case passCompletions = "1"
   case passYards = "3"
   case passTDs = "4"
   case rushAttempts = "23"
   case rushYards = "24"
   case rushTDs = "25"
   case receptions = "41"
   case receivingYards = "42"
   case receivingTDs = "43"
   case totalPoints = "53"
   case targets = "58"

   var name: String {
	  switch self {
		 case .passAttempts: return "Pass Attempts"
		 case .passCompletions: return "Pass Completions"
		 case .passYards: return "Pass Yards"
		 case .passTDs: return "Pass TDs"
		 case .rushAttempts: return "Rush Attempts"
		 case .rushYards: return "Rush Yards"
		 case .rushTDs: return "Rush TDs"
		 case .receptions: return "Receptions"
		 case .receivingYards: return "Receiving Yards"
		 case .receivingTDs: return "Receiving TDs"
		 case .totalPoints: return "Total Points"
		 case .targets: return "Targets"
	  }
   }
}
