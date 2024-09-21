import SwiftUI

struct PlayerDetailView: View {
   let player: PlayerModel
   let playerViewModel: PlayerViewModel
   var playerSize = 350.0
   let round: Int? // Add optional round parameter
   let pickNo: Int? // Add optional pickNo parameter
   @State private var isExpanded: Bool = false

   var body: some View {
	  let playerImageURL = URL(string: "https://sleepercdn.com/content/nfl/players/\(player.id).jpg")
	  let teamLogoURL = URL(string: "https://sleepercdn.com/i/teamlogos/nfl/500/\(player.team ?? "nfl").png")
	  let teamColor = Color(hex: "008C96") // TODO: need to get actual team color

	  VStack {
		 // Top Background Section with Player Image and Team Logo
		 ZStack(alignment: .bottomLeading) {
			RoundedRectangle(cornerRadius: 15)
			   .fill(LinearGradient(
				  gradient: Gradient(colors: [teamColor, .clear]),
				  startPoint: .top,
				  endPoint: .bottom
			   ))
			   .shadow(radius: 4)
			   .frame(height: 180)

			// Player and Team logo
			ZStack(alignment: .center) {
			   // Team Logo
			   if let teamLogoURL = teamLogoURL {
				  AsyncImage(url: teamLogoURL) { phase in
					 switch phase {
						case .empty:
						   Image(systemName: "photo")
							  .resizable()
							  .frame(width: 180, height: 180)
							  .opacity(0.5)
						case .success(let image):
						   image
							  .resizable()
							  .frame(width: 180, height: 180)
							  .offset(x: -15, y: 18)
							  .opacity(0.5)
							  .clipped()
						case .failure:
						   Image(systemName: "photo")
							  .resizable()
							  .frame(width: 180, height: 180)
							  .opacity(0.35)
						@unknown default:
						   EmptyView()
					 }
				  }
				  .padding(.bottom, -40)
				  .padding(.trailing, -42)
			   }

			   // Player Image
			   if let playerImageURL = playerImageURL {
				  AsyncImage(url: playerImageURL) { phase in
					 switch phase {
						case .empty:
						   Image(systemName: "person.crop.circle.fill")
							  .resizable()
							  .frame(width: 180, height: 180)
						case .success(let image):
						   image
							  .resizable()
							  .scaledToFill()
							  .frame(width: 180, height: 180)
							  .offset(x: -50)
							  .isOnIR(player.injuryStatus ?? "", hXw: 180)
						case .failure:
						   Image(systemName: "person.crop.circle.fill")
							  .resizable()
							  .frame(width: 180, height: 180)
						@unknown default:
						   EmptyView()
					 }
				  }
			   }
			   Spacer()
			}
			.padding()

			// Jersey Number Overlay
			VStack {
			   ZStack(alignment: .topLeading) {
				  // Jersey number
				  Text(player.number.map { "\($0)" } ?? "N/A")
					 .font(.system(size: 115, weight: .bold))
					 .italic()
					 .foregroundColor(teamColor.adjustBrightness(by: 0.5))
					 .opacity(0.35)

				  // # symbol, positioned at the top leading corner
				  Text("#")
					 .font(.system(size: 55, weight: .light))
					 .foregroundColor(teamColor.adjustBrightness(by: 0.25))
					 .offset(x: -10, y: 10)
			   }
			   .offset(x: 0, y: -70)
			}
			.frame(maxWidth: .infinity, alignment: .topTrailing)

			// Player Name Overlay on Top
			VStack {
			   Text(player.fullName ?? "Unknown Player")
				  .font(.system(size: 48))
				  .foregroundColor(teamColor.blended(withFraction: 0.55, of: .white))
				  .bold()
				  .lineLimit(1)
				  .minimumScaleFactor(0.5)
				  .padding(.trailing, 20)
				  .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
			}
			.offset(x: 100, y: -100)

			// Position and Status
			HStack {
			   Text("\(player.position ?? "N/A")\(player.depthChartOrder ?? 0)")
				  .font(.headline)
				  .foregroundColor(.white)
				  .bold()
				  .padding(.leading, 110)
				  .padding(.bottom, 60)
			   Spacer()
			}
			.opacity(0.65)
			.offset(y: -25)

			HStack {
			   Text("Status: \(player.status ?? "N/A")")
				  .font(.headline)
				  .foregroundColor(.white)
				  .bold()
				  .padding(.leading, 220)
				  .padding(.bottom, 60)
			   Spacer()
			}
			.opacity(0.5)
			.offset(y: -25)

			// Player Information Chevron in the header box
			HStack {
			   Spacer()
			   Button(action: {
				  withAnimation {
					 isExpanded.toggle()
				  }
			   }) {
				  Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
					 .foregroundColor(.white)
					 .font(.headline)
			   }
			}
			.padding(.trailing, 140)
			.padding(.bottom, 20)
		 }
		 .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 200)
		 .padding(.vertical, 4)
		 .padding(.horizontal, 4)
		 .clipped()
		 .cornerRadius(25.0)

		 // Player Info Section with Disclosure Group
		 if isExpanded {
			LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
			   PlayerInfoRowView(label: "Height", value: player.height)
			   PlayerInfoRowView(label: "Weight", value: player.weight)
			   PlayerInfoRowView(label: "Age", value: player.age?.description)
			   PlayerInfoRowView(label: "ID", value: player.id)
			   PlayerInfoRowView(label: "Team", value: player.team)
			   PlayerInfoRowView(label: "Position", value: player.position)
			   PlayerInfoRowView(label: "Status", value: player.status)
			   PlayerInfoRowView(label: "College", value: player.college)
			   PlayerInfoRowView(label: "Birth Country", value: player.birthCountry)
			   PlayerInfoRowView(label: "Years Experience", value: player.yearsExp?.description)
			   PlayerInfoRowView(label: "Number", value: player.number?.description)
			   PlayerInfoRowView(label: "Depth Chart Position", value: player.depthChartPosition?.description)
			   PlayerInfoRowView(label: "Depth Chart Order", value: player.depthChartOrder?.description)
			   if let round = round, let pickNo = pickNo {
				  PlayerInfoRowView(label: "Drafted", value: "Round \(round), Pick \(pickNo)")
			   }
			}
			.padding()
			.background(RoundedRectangle(cornerRadius: 15)
			   .fill(Color(teamColor).opacity(0.2)))
			.padding(.horizontal, 16)
			.offset(y: -25)
		 }

		 Spacer()
	  }
	  .preferredColorScheme(.dark)
   }

   @ViewBuilder
   private func PlayerInfoRowView(label: String, value: String?) -> some View {
	  if let value = value, !value.isEmpty {
		 VStack(alignment: .leading, spacing: 4) {
			Text("\(label):")
			   .font(.headline)
			   .foregroundColor(AppConstants.teamColor) // TODO: need to get the real teamColor from player.team
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
			   .scaledToFit()

			Text(value)
			   .font(.subheadline)
			   .fontWeight(.bold)
			   .lineLimit(1)
			   .minimumScaleFactor(0.5)
			   .scaledToFit()
			   .foregroundColor(.white)
		 }
		 .padding(.vertical, 4)
	  }
   }
}
