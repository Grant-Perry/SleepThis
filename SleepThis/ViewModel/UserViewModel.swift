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

   func fetchUserPublisher(by userID: String) -> AnyPublisher<UserModel?, Error> {
	  // Assuming you have a method to fetch user data from an API
	  let url = URL(string: "https://api.sleeper.app/v1/user/\(userID)")!
	  return URLSession.shared.dataTaskPublisher(for: url)
		 .map { $0.data }
		 .decode(type: UserModel?.self, decoder: JSONDecoder())
		 .receive(on: DispatchQueue.main)
		 .eraseToAnyPublisher()
   }
}

