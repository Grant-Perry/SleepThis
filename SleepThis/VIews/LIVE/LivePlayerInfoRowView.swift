import SwiftUI

struct LivePlayerInfoRowView: View {
   let label: String
   let value: String?

   var body: some View {
	  VStack(alignment: .leading, spacing: 4) {
		 Text("\(label):")
			.font(.headline)
			.foregroundColor(.gray)
			.lineLimit(1)
			.minimumScaleFactor(0.5)

		 Text(formattedValue(value))
			.font(.subheadline)
			.fontWeight(.bold)
			.lineLimit(1)
			.minimumScaleFactor(0.5)
			.foregroundColor(.white)
	  }
	  .padding(.vertical, 4)
   }

   // Helper function to format the value with 2 decimal places
   func formattedValue(_ value: String?) -> String {
	  guard let value = value, let doubleValue = Double(value) else {
		 return "N/A"
	  }
	  return String(format: "%.2f", doubleValue)
   }
}
