import SwiftUI

// ViewModifier to display version number at the bottom of the screen
struct VersionNumberModifier: ViewModifier {
   func body(content: Content) -> some View {
	  ZStack {
		 content

		 // The version number displayed at the bottom
		 VStack {
			Spacer() // Pushes the text to the bottom
			Text("Version: \(AppConstants.getVersion())")
			   .font(.system(size: AppConstants.verSize))
			   .foregroundColor(AppConstants.verColor)
//
//			Text(" - \(URL(fileURLWithPath: #file).deletingLastPathComponent().lastPathComponent)")
//			   .font(.footnote)
//			   .foregroundColor(.white)
////			   .padding(.bottom, 5) // Adjust padding as needed
		 }
		 .padding(.bottom, 50)
	  }
   }
}

extension View {
   func showVersionNumber() -> some View {
	  self.modifier(VersionNumberModifier())
   }
}
