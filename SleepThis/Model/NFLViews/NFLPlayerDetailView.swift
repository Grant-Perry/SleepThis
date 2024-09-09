import SwiftUI

struct NFLPlayerDetailView: View {
   let player: NFLRosterModel.NFLPlayer

   var body: some View {
	  VStack(alignment: .leading, spacing: 16) {
		 Text(player.fullName)
			.font(.largeTitle)
			.fontWeight(.bold)
		 Text("Team: \(player.teamName)")
			.font(.title2)
			.foregroundColor(.secondary)

		 // Show optional player details
		 if let position = player.position {
			Text("Position: \(position)")
			   .font(.headline)
		 }
		 if let jerseyNumber = player.jerseyNumber {
			Text("Jersey Number: #\(jerseyNumber)")
			   .font(.subheadline)
		 }
		 if let height = player.height {
			Text("Height: \(height)")
			   .font(.subheadline)
		 }
		 if let weight = player.weight {
			Text("Weight: \(weight) lbs")
			   .font(.subheadline)
		 }
		 if let age = player.age {
			Text("Age: \(age)")
			   .font(.subheadline)
		 }
		 if let experience = player.experience {
			Text("Experience: \(experience)")
			   .font(.subheadline)
		 }
		 if let college = player.college {
			Text("College: \(college)")
			   .font(.subheadline)
		 }
		 Spacer()
	  }
	  .padding()
	  .navigationTitle(player.fullName)
   }
}
