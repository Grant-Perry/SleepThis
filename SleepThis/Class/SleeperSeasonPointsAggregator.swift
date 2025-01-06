//
//  SleeperSeasonPointsAggregator.swift
//
//  Purpose:
//  - A brand new aggregator that calculates a given player’s season-to-date fantasy points
//    by directly calling Sleeper’s endpoints for weekly stats + scoring settings.
//  - Does NOT modify your existing code. It’s a standalone approach.
//  - If you already have "fetchSleeperScoringSettings()" in FantasyMatchupViewModel, we are *not* modifying it.
//    Instead, we replicate or re-fetch the same data here, purely so we do not change your production code.
//

import Foundation
import SwiftUI
import Combine

/// A brand new aggregator for Sleeper season points, not modifying your existing code.
class SleeperPointsAggregator: ObservableObject {

   /// We store Sleeper scoring settings once we fetch them from league/<leagueID>.
   private var sleeperLeagueSettings: [String: Any] = [:]

   /// A local dictionary of [playerID: [String: Double]] that sums up stats from multiple weeks
   /// so we can do a full season total. This aggregator does not rely on your existing code’s `playerStats`.
   private var seasonStats: [String: [String: Double]] = [:]

   // MARK: - Public Entry

   /// Summarize a single player's total points for weeks 1..upToWeek, using Sleeper’s scoring settings and stats endpoints.
   ///
   /// - Parameters:
   ///   - leagueID:  The Sleeper league ID to fetch scoring rules from (e.g. "1044844006657982464").
   ///   - playerID:  The Sleeper player ID (like "3086").
   ///   - upToWeek:  The final week (1..17 or 18).
   ///   - year:      e.g., 2023 for the season.
   /// - Returns:     The total season-to-date fantasy points.
   /// - Throws:      On networking/decoding errors.
   func getSeasonPointsForPlayer(leagueID: String,
								 playerID: String,
								 upToWeek: Int,
								 year: Int) async throws -> Double {
	  // 1. Ensure we have the league scoring settings
	  if sleeperLeagueSettings.isEmpty {
		 try await fetchLeagueScoringSettings(leagueID: leagueID)
	  }

	  // 2. For each week from 1..upToWeek, fetch the stats from Sleeper and accumulate in `seasonStats`
	  for week in 1...upToWeek {
		 try await fetchWeeklyStatsIfNeeded(year: year, week: week)
	  }

	  // 3. Sum the stats for the given player across all weeks
	  guard let aggregated = seasonStats[playerID] else {
		 // Means we never found stats for that player
		 return 0.0
	  }

	  // 4. Apply scoring
	  return applyScoringRules(stats: aggregated)
   }

   // MARK: - Private Helpers

   /// Grabs the league scoring settings from Sleeper (scoring_settings).
   private func fetchLeagueScoringSettings(leagueID: String) async throws {
	  guard let url = URL(string: "https://api.sleeper.app/v1/league/\(leagueID)") else {
		 throw URLError(.badURL)
	  }

	  let (data, response) = try await URLSession.shared.data(from: url)
	  if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
		 throw URLError(.badServerResponse)
	  }

	  // Parse JSON
	  if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
		 let settings = json["scoring_settings"] as? [String: Any] {
		 sleeperLeagueSettings = settings
	  }
   }

   /// Fetch weekly stats for all players from Sleeper if not cached in `seasonStats`.
   /// Endpoint: GET /stats/nfl/regular/<year>/<week>
   private func fetchWeeklyStatsIfNeeded(year: Int, week: Int) async throws {
	  // For example, we'll assume if we've never stored anything, we do a fresh fetch.
	  // This aggregator lumps each week's stats into `seasonStats`.
	  // If you want more advanced caching, you'd store it on disk or check a memory flag.

	  guard let url = URL(string: "https://api.sleeper.app/v1/stats/nfl/regular/\(year)/\(week)") else {
		 throw URLError(.badURL)
	  }

	  let (data, response) = try await URLSession.shared.data(from: url)
	  if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
		 throw URLError(.badServerResponse)
	  }

	  // The data is a JSON dictionary of [playerID: [statKey: Double]] e.g. "3086": {"pass_yd": 275, ...}
	  if let topDict = try JSONSerialization.jsonObject(with: data) as? [String: [String: Double]] {
		 // Merge each player's weekly stats into `seasonStats`.
		 for (pid, statsMap) in topDict {
			// If we already have partial stats, add new values on top
			var existing = seasonStats[pid] ?? [:]
			for (statKey, statValue) in statsMap {
			   existing[statKey] = (existing[statKey] ?? 0.0) + statValue
			}
			seasonStats[pid] = existing
		 }
	  }
   }

   /// Apply the league’s scoring rules to a dictionary of aggregated stats.
   private func applyScoringRules(stats: [String: Double]) -> Double {
	  var totalPoints = 0.0
	  for (statKey, statValue) in stats {
		 if let multiplier = sleeperLeagueSettings[statKey] as? Double {
			totalPoints += statValue * multiplier
		 }
	  }
	  return totalPoints
   }
}
