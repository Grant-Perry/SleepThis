import SwiftUI

class SleepThisViewModel: ObservableObject {
   struct ScaledButtonStyle: ButtonStyle {
	  func makeBody(configuration: Configuration) -> some View {
		 configuration.label
			.scaleEffect(0.8)
	  }
   }
}
