//
//  SleeperRecordAggregator.swift
//
//  Purpose:
//  - A brand new aggregator/view model that fetches the manager’s overall record from Sleeper.
//  - Does NOT modify any existing code in your project.
//  - We simply create a separate aggregator that fetches rosters from Sleeper and returns a record string.
//  - Usage:  let record = try await SleeperRecordAggregator().getManagerRecord(leagueID: "XXX", ownerID: "YYY")
//

import Foundation
import SwiftUI
import Combine

/// A brand new aggregator that retrieves a manager’s overall record (wins-losses[-ties]) from Sleeper.
/// This does not modify or replace any of your existing logic. It's a standalone approach.
class SleeperRecordAggregator: ObservableObject {

   /// Fetch and return the manager’s record for a given league + owner.
   /// - Parameters:
   ///   - leagueID: The Sleeper league ID (e.g., "1044844006657982464")
   ///   - ownerID:  The user/owner ID (e.g., "1117588009542615040")
   /// - Returns:    Formatted string like "14-3" or "10-4-2"
   /// - Throws:     Error if network fails or no roster found for that owner
   func getManagerRecord(leagueID: String, ownerID: String) async throws -> String {
	  // Create endpoint
	  guard let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)/rosters") else {
		 throw URLError(.badURL)
	  }

	  // Execute network call
	  let (data, response) = try await URLSession.shared.data(from: url)

	  // Check status
	  if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
		 throw URLError(.badServerResponse)
	  }

	  // Decode rosters
	  let rosters = try JSONDecoder().decode([SleeperRoster].self, from: data)

	  // Locate target
	  guard let myRoster = rosters.first(where: { $0.owner_id == ownerID }) else {
		 throw NSError(domain: "SleeperRecordAggregator",
					   code: -1,
					   userInfo: [NSLocalizedDescriptionKey: "No roster found for owner: \(ownerID)"])
	  }

	  let wins = myRoster.settings?.wins ?? 0
	  let losses = myRoster.settings?.losses ?? 0
	  let ties = myRoster.settings?.ties ?? 0

	  if ties > 0 {
		 return "\(wins)-\(losses)-\(ties)"
	  } else {
		 return "\(wins)-\(losses)"
	  }
   }
}
