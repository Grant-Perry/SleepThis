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

			Text("League ID: \(league.leagueID)")
			   .font(.caption)
			   .foregroundColor(.gray)

			Text("Season: \(league.season)")
			   .font(.subheadline)
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

			// Roster Positions Section
			DisclosureGroup(isExpanded: $showRosterPositions) {
			   VStack {
				  ForEach(league.rosterPositions, id: \.self) { position in
					 Text("\(position)")
						.font(.subheadline)
						.foregroundColor(.gpWhite)
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

			/// Navigation to Manager List
			NavigationLink(destination: ManagerListView(
			   draftViewModel: DraftViewModel(leagueID: league.leagueID), // Pass leagueID
			   rosterViewModel: RosterViewModel(leagueID: league.leagueID, draftViewModel: DraftViewModel(leagueID: league.leagueID)),
			   leagueID: league.leagueID, // Use leagueID from league model
			   draftID: league.draftID ?? AppConstants.draftID, // Use draftID from league model or fallback
			   viewType: .roster
			)) {
			   Text("View Rosters")
				  .font(.headline)
				  .padding()
				  .frame(maxWidth: .infinity)
				  .background(Color.blue)
				  .foregroundColor(.white)
				  .cornerRadius(10)
				  .padding(.horizontal)
			}
		 }
		 .padding()
		 .navigationTitle("League Details")
	  }
   }
}
