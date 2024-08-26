import Foundation
import Combine

class UserViewModel: ObservableObject {
   @Published var user: UserModel?
   @Published var isLoading = false
   @Published var errorMessage: String?

   private let userCacheKey = "cachedUser"
   private let cacheDateKey = "userCacheDateKey"

   func fetchUser(by lookup: String, completion: @escaping () -> Void) {
	  isLoading = true
	  errorMessage = nil

	  let urlString: String
	  if lookup.allSatisfy(\.isNumber) {
		 urlString = "https://api.sleeper.app/v1/user/\(lookup)"
	  } else {
		 urlString = "https://api.sleeper.app/v1/user/\(lookup)"
	  }

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
			   self.saveUserToCache(user)
			} catch {
			   self.errorMessage = "Failed to decode user data: \(error)"
			}
			completion()
		 }
	  }.resume()
   }

   func loadCachedUser() {
	  guard let cachedData = UserDefaults.standard.data(forKey: userCacheKey) else {
		 errorMessage = "No cached user data available"
		 return
	  }

	  do {
		 let cachedUser = try JSONDecoder().decode(UserModel.self, from: cachedData)
		 self.user = cachedUser
	  } catch {
		 self.errorMessage = "Failed to decode cached user data: \(error)"
	  }
   }

   func reloadCache() {
	  loadCachedUser()
   }

   private func saveUserToCache(_ user: UserModel) {
	  let defaults = UserDefaults.standard
	  if let data = try? JSONEncoder().encode(user) {
		 defaults.set(data, forKey: userCacheKey)
		 defaults.set(Date(), forKey: cacheDateKey)
	  }
   }
}
