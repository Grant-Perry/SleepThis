import SwiftUI

struct ManagerRowView: View {
   let managerID: String
   let leagueID: String
   @ObservedObject var draftViewModel: DraftViewModel
   @ObservedObject var rosterViewModel: RosterViewModel
   let thisBackgroundColor: Color
   let viewType: ManagerViewType
   @State private var showLeagueListView = false

   // A computed property to find the matching roster
   private var matchingRoster: RosterModel? {
	  rosterViewModel.rosters.first { $0.ownerID == managerID }
   }

   var body: some View {
	  NavigationLink(destination: destinationView(for: matchingRoster)) {
		 HStack {
			// Manager's avatar
			if let avatarURL = draftViewModel.managerAvatar(for: managerID) {
			   AsyncImage(url: avatarURL) { image in
				  image.resizable()
					 .aspectRatio(contentMode: .fill)
					 .frame(width: 60, height: 60)
					 .clipShape(Circle())
					 .padding(.leading, 16)
			   } placeholder: {
				  Image(systemName: "person.crop.circle")
					 .resizable()
					 .frame(width: 60, height: 60)
					 .padding(.leading, 16)
			   }
			} else {
			   Image(systemName: "person.crop.circle")
				  .resizable()
				  .frame(width: 60, height: 60)
				  .padding(.leading, 16)
			}

			VStack(alignment: .leading) {
			   Text(draftViewModel.managerName(for: managerID))
				  .font(.title2)
				  .foregroundColor(.gpDark2)
				  .bold()

			   Button(action: {
				  showLeagueListView = true
			   }) {
				  Text("\(managerID)")
					 .font(.footnote)
					 .foregroundColor(.blue)
			   }

			   if let draftSlot = draftViewModel.groupedPicks[managerID]?.first?.draft_slot {
				  Text("Draft Pick #:\(draftSlot)")
					 .font(.caption2)
					 .foregroundColor(.gpDark1)
					 .padding(.leading, 10)
			   } else {
				  Text("")
					 .font(.subheadline)
					 .padding(.leading, 10)
			   }
			}

			Spacer()

			Image(systemName: "chevron.right")
			   .resizable()
			   .frame(width: 8, height: 8)
			   .padding(.trailing, 10)
			   .foregroundColor(.gpDark1)
		 }
		 .padding(.vertical, 15)
		 .padding(.horizontal, 16)
		 .background(
			RoundedRectangle(cornerRadius: 15)
			   .fill(LinearGradient(
				  gradient: Gradient(colors: [
					 thisBackgroundColor,
					 thisBackgroundColor.blended(withFraction: 0.55, of: .white)
				  ]),
				  startPoint: .top,
				  endPoint: .bottom
			   ))
			   .shadow(radius: 4)
		 )
		 .padding(.vertical, 4)
		 .padding(.horizontal, 4)
	  }
	  .sheet(isPresented: $showLeagueListView) {
		 LeagueListView(
			managerID: managerID,
			draftViewModel: draftViewModel
		 )
	  }
	  .onAppear {
		 // Debug prints when the view appears
		 print("DP - ManagerRowView appeared for managerID:", managerID)
		 print("DP - Available rosters count:", rosterViewModel.rosters.count)
		 for (index, roster) in rosterViewModel.rosters.enumerated() {
			print("DP - Roster \(index): ownerID = \(roster.ownerID), players count = \(roster.players.count)")
		 }

		 if let matchingRoster = matchingRoster {
			print("DP - Found matching roster for managerID \(managerID): ownerID = \(matchingRoster.ownerID)")
		 } else {
			print("DP - No matching roster found for managerID \(managerID)")
		 }

		 let managerName = draftViewModel.managerName(for: managerID)
		 print("DP - managerName for \(managerID): \(managerName)")
	  }
   }

   @ViewBuilder
   private func destinationView(for roster: RosterModel?) -> some View {
	  if viewType == .draft {
		 DraftListView(
			managerID: managerID,
			draftViewModel: draftViewModel,
			backgroundColor: thisBackgroundColor
		 )
	  } else if let roster = roster {
		 RosterDetailView(
			leagueID: leagueID,
			managerID: roster.ownerID,
			managerName: draftViewModel.managerName(for: managerID),
			managerAvatarURL: draftViewModel.managerAvatar(for: managerID),
			draftViewModel: draftViewModel,
			rosterViewModel: rosterViewModel
		 )
		 .onAppear {
			print("DP - RosterDetailView onAppear for managerID:", managerID)
			print("DP - Checking roster detail. ownerID:", roster.ownerID)
			let foundRoster = rosterViewModel.rosters.first { $0.ownerID == roster.ownerID }
			if let foundRoster = foundRoster {
			   print("DP - Found roster in RosterDetailView: players count =", foundRoster.players.count)
			} else {
			   print("DP - No roster found in RosterDetailView for ownerID \(roster.ownerID)")
			}
		 }
	  } else {
		 Text("Roster not found for this manager.")
			.foregroundColor(.red)
	  }
   }
}
