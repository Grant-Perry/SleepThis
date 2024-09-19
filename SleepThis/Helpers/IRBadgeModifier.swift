import SwiftUI

struct IRBadgeModifier: ViewModifier {
   var isOnIR: Bool
   var hXw: CGFloat

   func body(content: Content) -> some View {
	  ZStack(alignment: .bottomTrailing) {
		 content
		 if isOnIR {
			ZStack {
			   Text("IR")
				  .font(.system(size: hXw / 6))
				  .foregroundColor(.red)
				  .bold()
			}
			.frame(width: hXw, height: hXw)
			.offset(x: -hXw, y: hXw)
		 }
	  }
	  .frame(width: hXw, height: hXw) // Apply hXw to both width and height of the main frame
   }
}

// Extension to make it easier to use the modifier
extension View {
   func isOnIR(_ status: String, hXw: CGFloat) -> some View {
	  self.modifier(IRBadgeModifier(isOnIR: status == "IR", hXw: hXw))
   }
}
