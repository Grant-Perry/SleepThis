import Foundation
import Observation

@Observable

class CacheManager {
   static let shared = CacheManager()
   private init() {}

   func getCacheDirectory() -> URL {
	  let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
	  let cacheDirectory = paths[0].appendingPathComponent("CachedData")

	  // Ensure directory exists
	  if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
		 do {
			try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
		 } catch {
			print("[getCacheDirectory:] Failed to create cache directory: \(error.localizedDescription)")
		 }
	  }

	  return cacheDirectory
   }

   func saveToCache<T: Encodable>(_ data: T, as fileName: String) {
	  let cacheURL = getCacheDirectory().appendingPathComponent(fileName)

	  do {
		 let encodedData = try JSONEncoder().encode(data)
		 try encodedData.write(to: cacheURL)
		 print("[saveToCache:] Successfully saved data to cache at \(cacheURL.path)")
	  } catch {
		 print("[saveToCache:] Failed to save data to cache: \(error.localizedDescription)")
	  }
   }

   func loadFromCache<T: Decodable>(_ fileName: String, as type: T.Type) -> T? {
	  let url = getCacheDirectory().appendingPathComponent(fileName)

	  guard FileManager.default.fileExists(atPath: url.path) else {
		 print("[loadFromCache:] Cache file does not exist. Fetching data from network.")
		 return nil
	  }

	  do {
		 let data = try Data(contentsOf: url)
		 let object = try JSONDecoder().decode(type, from: data)
		 return object
	  } catch {
		 print("[loadFromCache:] Failed to load data from cache: \(error.localizedDescription)")
		 return nil
	  }
   }
}
