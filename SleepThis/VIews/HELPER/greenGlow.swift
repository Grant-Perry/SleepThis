import SwiftUI

struct Green: View {

   var corner:CGFloat = 10
   var thisWidth:CGFloat = 200
   var thisHeight:CGFloat = 200


   var body: some View {
	  ZStack {
		 // Background color to see the glow effect clearly
		 Color.black
			.edgesIgnoringSafeArea(.all)

		 // The rounded rectangle with gradient background, stroke, and glow
		 RoundedRectangle(cornerRadius: corner)
			.shadow(color: Color.green.opacity(0.8), radius: 5, x: 0, y: 0) // Green glow
			.frame(width: thisWidth, height: thisHeight) // Fixed size
			.overlay(
			   RoundedRectangle(cornerRadius: corner)
				  .stroke(Color.gpWhite, lineWidth: 1) // White stroke
			)
			.shadow(color: Color.green.opacity(0.9), radius: 10, x: 0, y: 0) // This one on makes it SUPER
	  }
   }
}

struct Green_Previews: PreviewProvider {
   static var previews: some View {
	  Green()
   }
}
