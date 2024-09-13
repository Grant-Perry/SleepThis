import SwiftUI

struct PlayerInfoRowView: View {
   let label: String
   let value: String?

   var body: some View {
	  if let value = value, !value.isEmpty {
		 HStack {
			Text(label + ":")
			   .font(.subheadline)
			   .foregroundColor(.gray)
			Spacer()
			Text(value)
			   .font(.subheadline)
		 }
		 .padding(.vertical, 2)
	  }
   }
}
