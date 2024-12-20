import SwiftUI

struct GreenGlowModifier: ViewModifier {
   var isActive: Bool
   var corner: CGFloat = 15
   var glow: Color = Color.green.opacity(0.5)

   func body(content: Content) -> some View {
	  content
		 .shadow(color: isActive ? glow : .black, radius: 10, x: 0, y: 0)
		 .clipShape(RoundedRectangle(cornerRadius: corner))
   }
}
