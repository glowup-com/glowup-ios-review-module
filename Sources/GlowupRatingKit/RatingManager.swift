import Foundation
import StoreKit
#if canImport(UIKit)
import UIKit
#endif

/// Actor responsible for managing app rating requests
@MainActor
@Observable
public final class RatingManager {
    private let configuration: Configuration
    private let storage: RatingStorage
    private let sentimentGate: SentimentGate?
    
    /// Initialize the RatingManager with configuration
    /// - Parameters:
    ///   - configuration: The configuration for rating behavior
    ///   - userDefaults: UserDefaults instance for persistence (defaults to .standard)
    public init(
        configuration: Configuration,
        userDefaults: UserDefaults = .standard
    ) {
        self.configuration = configuration
        self.storage = RatingStorage(userDefaults: userDefaults)
        
        if let sentimentConfig = configuration.sentimentGateConfiguration {
            self.sentimentGate = SentimentGate(configuration: sentimentConfig, storage: storage)
        } else {
            self.sentimentGate = nil
        }
    }
    
    // MARK: - Public API
    
    /// Call this method when the app session starts
    public func recordAppSession() {
        storage.incrementAppSessionCount()
    }
    
    /// Call this method when a successful flow completes
    public func recordSuccessFlow() {
        storage.incrementSuccessFlowCount()
    }
    
    /// Check if conditions are met to show rating prompt
    public func shouldShowRatingPrompt() -> Bool {
        // Check if minimum sessions and success flows are met
        guard storage.appSessionCount >= configuration.minimumAppSessions,
              storage.successFlowCount >= configuration.minimumSuccessFlows else {
            return false
        }
        
        // Check if we've shown a rating prompt recently (Apple's guideline: not more than 3 times per year)
        if let lastRequestDate = storage.lastRatingRequestDate {
            let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastRequestDate, to: Date()).day ?? 0
            if daysSinceLastRequest < 120 { // ~4 months
                return false
            }
        }
        
        // If sentiment gate is configured, check if user likes the app
        if let sentimentGate = sentimentGate {
            if storage.hasShownSentimentGate && !sentimentGate.userLikesApp() {
                return false
            }
        }
        
        return true
    }
    
    /// Request rating from the user
    /// - Returns: True if sentiment gate should be shown first, false if rating was requested directly
    public func requestRating() async -> Bool {
        guard shouldShowRatingPrompt() else {
            return false
        }
        
        // If sentiment gate is configured and hasn't been shown yet
        if let sentimentGate = sentimentGate, sentimentGate.shouldShowSentimentGate() {
            return true // Indicate that sentiment gate should be shown
        }
        
        // Show Apple's rating prompt directly
        await showAppleRatingPrompt()
        return false
    }
    
    /// Handle positive sentiment gate response
    public func handlePositiveSentimentResponse() async {
        sentimentGate?.handlePositiveResponse()
        
        // Proceed to show Apple rating prompt
        await showAppleRatingPrompt()
    }
    
    /// Handle negative sentiment gate response
    /// - Parameter openFeedbackURL: Whether to open the feedback URL if configured
    public func handleNegativeSentimentResponse(openFeedbackURL: Bool = true) {
        sentimentGate?.handleNegativeResponse(openFeedbackURL: openFeedbackURL)
    }
    
    /// Get current statistics
    public func getStatistics() -> (appSessions: Int, successFlows: Int, lastRatingDate: Date?) {
        return storage.getStatistics()
    }
    
    /// Reset all stored data (useful for testing or user privacy)
    public func resetData() {
        storage.resetAllData()
    }
    
    // MARK: - Private Methods
    
    private func showAppleRatingPrompt() async {
        storage.recordRatingRequest()
        
        #if canImport(UIKit)
        if let windowScene = await getActiveWindowScene() {
            AppStore.requestReview(in: windowScene)
        }
        #else
        SKStoreReviewController.requestReview()
        #endif
    }
    
    #if canImport(UIKit)
    private func getActiveWindowScene() async -> UIWindowScene? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
            return nil
        }
        return windowScene
    }
    #endif
}


