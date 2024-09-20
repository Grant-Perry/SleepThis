import SwiftUI

struct DummyPlayerDetailView: View {
   let playerSize = 350.0
   let playerImageURL = URL(string: "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/4241479.png")!
   let teamLogoURL = URL(string: "https://a.espncdn.com/i/teamlogos/nfl/500/mia.png")!
   let teamColor = Color(hex: "008C96")
   @State private var isExpanded: Bool = false

   var body: some View {
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

			   // Player Image
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
						   .isOnIR("IR", hXw: 180)
					 case .failure:
						Image(systemName: "person.crop.circle.fill")
						   .resizable()
						   .frame(width: 180, height: 180)
					 @unknown default:
						EmptyView()
				  }
			   }
			   Spacer()
			}
			.padding()

			// Jersey Number Overlay
			VStack {
			   ZStack(alignment: .topLeading) {
				  // Jersey number
				  Text("1")
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
			   Text("Tua Tagovailoa")
				  .font(.system(size: 48))
				  .foregroundColor(teamColor.blended(withFraction: 0.55, of: .white))
				  .bold()
				  .lineLimit(1)
				  .minimumScaleFactor(0.5)
				  .padding(.trailing, 20)
				  .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
			}
			.offset(x: 100, y: -100)

			// Position
			HStack {
			   Text("QB-1")
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
			   Text("Status: Inactive")
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
//			   Text("Player Information")
//				  .font(.headline)
//				  .foregroundColor(.white)
			   Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
				  .foregroundColor(.white)
				  .font(.headline)
			}
			.padding(.trailing, 140)
			.padding(.bottom, 20)
			.onTapGesture {
			   withAnimation {
				  isExpanded.toggle()
			   }
			}
		 }
		 .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 200)
		 .padding(.vertical, 4)
		 .padding(.horizontal, 4)
		 .clipped()
		 .cornerRadius(25.0)

		 // Player Info Section with Disclosure Group
		 DisclosureGroup("", isExpanded: $isExpanded) {
			LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
			   PlayerInfoRowView(label: "Height", value: "6'2\"")
			   PlayerInfoRowView(label: "Weight", value: "220 lbs.")
			   PlayerInfoRowView(label: "Age", value: "28")
			   PlayerInfoRowView(label: "ID", value: "12345")
			   PlayerInfoRowView(label: "Team", value: "Miami Dolphins")
			   PlayerInfoRowView(label: "Position", value: "QB")
			   PlayerInfoRowView(label: "Status", value: "Active")
			   PlayerInfoRowView(label: "College", value: "University of Nowhere")
			   PlayerInfoRowView(label: "Birth Country", value: "USA")
			   PlayerInfoRowView(label: "Years Experience", value: "5")
			   PlayerInfoRowView(label: "Number", value: "1")
			   PlayerInfoRowView(label: "Depth Chart Position", value: "1")
			   PlayerInfoRowView(label: "Depth Chart Order", value: "1")
			   PlayerInfoRowView(label: "Drafted", value: "Round 1, Pick 5")
			}
			.padding()
			.background(RoundedRectangle(cornerRadius: 15)
			   .fill(Color.gpGray.opacity(0.2)))
			.padding(.horizontal, 16)
//			.offset(y: -45)
		 }
		 .padding(.horizontal, 16)
		 .background(RoundedRectangle(cornerRadius: 15)
			.fill(Color(teamColor).opacity(0.2)))
		 .offset(y: -50)


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
			   .foregroundColor(teamColor)
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

struct DummyPlayerDetailView_Previews: PreviewProvider {
   static var previews: some View {
	  DummyPlayerDetailView()
		 .previewLayout(.sizeThatFits)
   }
}
