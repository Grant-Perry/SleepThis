import SwiftUI

struct ContentView: View {
   var body: some View {
	  ZStack {
		 // Background color to see the glow effect clearly
		 Color.black
			.edgesIgnoringSafeArea(.all)

		 // The rounded rectangle with gradient background, stroke, and glow
		 RoundedRectangle(cornerRadius: 20)
			.fill(
			   LinearGradient(
				  gradient: Gradient(colors: [.black, .gray]),
				  startPoint: .top,
				  endPoint: .bottom
			   )
			)
			.frame(width: 200, height: 200) // Fixed size
			.overlay(
			   RoundedRectangle(cornerRadius: 20)
				  .stroke(Color.white, lineWidth: 2) // White stroke
			)
			.shadow(color: Color.green.opacity(0.9), radius: 20, x: 0, y: 0) // Green glow
	  }
   }
}

struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
	  ContentView()
   }
}
