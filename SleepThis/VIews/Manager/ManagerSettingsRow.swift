import SwiftUI

// A custom view for aligned label-value pairs
struct ManagerSettingsRow: View {
   var label: String
   var value: String

   var body: some View {
	  HStack(spacing: 1) {

		 Text(label)
			.font(.footnote)
			.bold()
			.lineLimit(1)
			.minimumScaleFactor(0.5)
			.scaledToFit()
			.padding(.leading, 1)
			.frame(width: 60, alignment: .trailing)

		 Text(" \(value)")
			.font(.footnote)
			.foregroundColor(.gpYellow)
			.lineLimit(1)
			.minimumScaleFactor(0.5)
			.scaledToFit()
			.padding(.trailing, 1)

	  }
   }
}
