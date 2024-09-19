import SwiftUI

struct IRBadgeModifier: ViewModifier {
   var isOnIR: Bool
   var hXw: CGFloat

   func body(content: Content) -> some View {
	  ZStack(alignment: .bottomTrailing) {
		 content
		 if isOnIR {
			Text("IR")
			   .font(.system(size: 25)) // Set fixed size for the text
			   .foregroundColor(.red)
			   .bold()
			   .padding(5)
			   .background(Color.white.opacity(0.8)) // White background with some opacity
			   .clipShape(Circle())
			   .offset(x: 10, y: 10) // Adjust as needed for positioning
		 }
	  }
	  .frame(width: hXw, height: hXw)
   }
}

// Extension to make it easier to use the modifier
extension View {
   func isOnIR(_ status: String, hXw: CGFloat) -> some View {
	  self.modifier(IRBadgeModifier(isOnIR: status == "IR", hXw: hXw))
   }
}
