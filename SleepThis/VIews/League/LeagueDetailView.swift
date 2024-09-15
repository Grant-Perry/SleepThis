import SwiftUI

struct LeagueDetailView: View {
   let league: LeagueModel
   @State private var showScoringSettings = false
   @State private var showRosterPositions = false
   @State private var showLeagueSettings = false

   var body: some View {
	  ScrollView {
		 VStack(alignment: .leading) {
			// League Info
			Text("\(league.name)")
			   .font(.title)
			   .foregroundColor(.gpGreen)
			   .frame(maxWidth: .infinity)
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
			   .scaledToFit()
			   .padding(.bottom, 5)

			Group {
			   Text("League ID: \(league.leagueID)")
				  .font(.caption)
				  .foregroundColor(.gray)

			   Text("Season: ")
				  .font(.subheadline) +
			   Text("\(league.season)")
				  .font(.title3)
				  .foregroundColor(.gpBlue)
			}
			   .padding(.top, 5)

			Text("Total Rosters: \(league.totalRosters)")
			   .font(.subheadline)
			   .padding(.bottom, 5)

			// Scoring Settings Section
			DisclosureGroup(isExpanded: $showScoringSettings) {
			   VStack {
				  ForEach(league.scoringSettings.sorted(by: >), id: \.key) { key, value in
					 HStack {
						Text("\(key.capitalized):")
						   .font(.subheadline)
						   .foregroundColor(.gpWhite)

						Spacer()

						Text("\(value, specifier: "%.2f")")
						   .font(.subheadline)
						   .foregroundColor(.gpBlue)
					 }
					 .padding(.vertical, 3)
					 Divider()
				  }
			   }
			   .padding(.horizontal)
			} label: {
			   Text("Scoring Settings")
				  .font(.title2)
				  .bold()
				  .padding(.vertical, 5)
			}

			// CALCULATED Roster Positions Section
			DisclosureGroup(isExpanded: $showRosterPositions) {
			   VStack(alignment: .leading, spacing: 5) {
				  // Create a dictionary to count occurrences of each position
				  let positionCounts = league.rosterPositions.reduce(into: [:]) { counts, position in
					 counts[position, default: 0] += 1
				  }

				  // Specify the order and labels for the positions
				  let positionOrder = ["QB", "RB", "WR", "TE", "FLEX", "K", "BN", "DEF"]

				  // Display each position on its own line with trailing aligned labels and leading aligned values
				  ForEach(positionOrder, id: \.self) { position in
					 HStack {
						// Position label aligned to the trailing
						Text("\(position):")
						   .font(.subheadline)
						   .foregroundColor(.gpWhite)
						   .frame(width: 40, alignment: .trailing)  // Align the labels to the trailing with fixed width

						// Value aligned to the leading
						Text("\(positionCounts[position, default: 0])")
						   .font(.subheadline)
						   .foregroundColor(.gpBlue)
						   .frame(alignment: .leading)  // Align the value to the leading
					 }
				  }
			   }
			   .padding(.horizontal)
			} label: {
			   Text("Roster Positions")
				  .font(.title2)
				  .bold()
				  .padding(.vertical, 5)
			}



			// League Settings Section
			DisclosureGroup(isExpanded: $showLeagueSettings) {
			   VStack {
				  HStack {
					 Text("Max Keepers:")
						.font(.subheadline)
						.foregroundColor(.gpWhite)

					 Spacer()

					 Text("\(league.settings.maxKeepers ?? 0)")
						.font(.subheadline)
						.foregroundColor(.gpBlue)
				  }
				  .padding(.vertical, 3)
				  Divider()

				  HStack {
					 Text("Draft Rounds:")
						.font(.subheadline)
						.foregroundColor(.gpWhite)

					 Spacer()

					 Text("\(league.settings.draftRounds ?? 0)")
						.font(.subheadline)
						.foregroundColor(.gpBlue)
				  }
				  .padding(.vertical, 3)
				  Divider()

				  HStack {
					 Text("Playoff Teams:")
						.font(.subheadline)
						.foregroundColor(.gpWhite)

					 Spacer()

					 Text("\(league.settings.playoffTeams ?? 0)")
						.font(.subheadline)
						.foregroundColor(.gpBlue)
				  }
				  .padding(.vertical, 3)
				  Divider()
			   }
			   .padding(.horizontal)
			} label: {
			   Text("League Settings")
				  .font(.title2)
				  .bold()
				  .padding(.vertical, 5)
			}

			Spacer()
			Spacer()

			/// Navigation to Manager List
			NavigationLink(destination: ManagerListView(
			   draftViewModel: DraftViewModel(leagueID: league.leagueID), // Pass leagueID
			   rosterViewModel: RosterViewModel(leagueID: league.leagueID, draftViewModel: DraftViewModel(leagueID: league.leagueID)),
			   leagueID: league.leagueID,
			   draftID: league.draftID ?? AppConstants.draftID,
			   viewType: .roster
			)) {
			   Text("View Rosters")
				  .font(.headline)
				  .padding()
				  .frame(maxWidth: .infinity)
				  .background(Color.blue.gradient)
				  .foregroundColor(.white)
				  .cornerRadius(10)
				  .padding(.horizontal)
			}
			.padding(.top, 40)


		 }
		 .padding()
		 .navigationTitle("League Details")
	  }
   }
}
