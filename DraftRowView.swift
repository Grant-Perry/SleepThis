import SwiftUI

struct DraftRowView: View {
   let draft: DraftModel

   var body: some View {
	  HStack {
		 VStack(alignment: .leading) {
			Text("\(draft.metadata?.first_name ?? "") \(draft.metadata?.last_name ?? "")")
			   .font(.headline)
			Text(draft.metadata?.position ?? "")
			   .font(.subheadline)
			Text(draft.metadata?.team ?? "")
			   .font(.subheadline)
		 }
		 Spacer()
		 Text("Round \(draft.round)")
			.font(.subheadline)
	  }
	  .padding(.vertical, 4)
   }
}
