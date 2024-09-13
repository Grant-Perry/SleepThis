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
			   .padding(.bottom) // Adjust padding as needed
		 }
	  }
   }
}

extension View {
   func showVersionNumber() -> some View {
	  self.modifier(VersionNumberModifier())
   }
}
