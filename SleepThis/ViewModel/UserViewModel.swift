import Foundation
import Combine

class UserViewModel: ObservableObject {
   @Published var user: UserModel?
   @Published var isLoading = false
   @Published var errorMessage: String?

   func fetchUser(by lookup: String, completion: @escaping () -> Void = {}) {
	  isLoading = true
	  errorMessage = nil

	  // Try to load from cache first
	  if let cachedUser = CacheManager.shared.loadFromCache(lookup, as: UserModel.self) {
		 self.user = cachedUser
		 self.isLoading = false
		 completion()
		 return
	  }

	  let urlString = "https://api.sleeper.app/v1/user/\(lookup)"

	  guard let url = URL(string: urlString) else {
		 self.errorMessage = "Invalid URL"
		 completion()
		 return
	  }

	  URLSession.shared.dataTask(with: url) { data, response, error in
		 DispatchQueue.main.async {
			self.isLoading = false

			if let error = error {
			   self.errorMessage = error.localizedDescription
			   completion()
			   return
			}

			guard let data = data else {
			   self.errorMessage = "No data received"
			   completion()
			   return
			}

			do {
			   let user = try JSONDecoder().decode(UserModel.self, from: data)
			   self.user = user
			   CacheManager.shared.saveToCache(user, as: lookup)
			   completion()
			} catch {
			   self.errorMessage = "Failed to decode user data: \(error)"
			   completion()
			}
		 }
	  }.resume()
   }
}

