import Foundation
import StoreKit
#if canImport(UIKit)
import UIKit
#endif

/// Simple rating manager with sentiment gate functionality
@MainActor
@Observable
public final class RatingManager {
    
    // MARK: - Public Properties
    
    /// Whether the next rating request will show a sentiment gate or go straight to Apple review
    public var willShowSentimentGate: Bool {
        return configuration.enableSentimentGate && !sentimentGateCompleted
    }
    
    /// Configuration for the rating manager
    public let configuration: Configuration
    
    // MARK: - Private Properties
    private var sentimentGateCompleted: Bool = false
    private let userDefaults: UserDefaults
    private let sentimentGateKey = "com.glowup.ratingkit.sentimentGateCompleted"
    
    // MARK: - Initialization
    
    public init(configuration: Configuration, userDefaults: UserDefaults = .standard) {
        self.configuration = configuration
        self.userDefaults = userDefaults
        self.sentimentGateCompleted = userDefaults.bool(forKey: sentimentGateKey)
    }
    
    // MARK: - Public Methods
    
    /// Request a rating from the user
    /// This will show the sentiment gate first if enabled and not completed
    public func requestRating() {
        if configuration.enableSentimentGate && !sentimentGateCompleted {
            // open sentiment gate
            print("🚀 Will open sentiment gate now!")
        } else {
            showAppStoreReview()
        }
    }
    
    /// Handle positive response from sentiment gate
    public func handlePositiveResponse() {
        markSentimentGateCompleted()
        showAppStoreReview()
    }
    
    /// Handle negative response from sentiment gate
    public func handleNegativeResponse() {
        markSentimentGateCompleted()
        
        // Open feedback URL if provided
        if let feedbackURL = configuration.feedbackURL {
            #if canImport(UIKit)
            UIApplication.shared.open(feedbackURL)
            #endif
        }
    }
    
    /// Reset the sentiment gate state (useful for testing)
    public func resetSentimentGate() {
        userDefaults.removeObject(forKey: sentimentGateKey)
        sentimentGateCompleted = false
    }
    
    // MARK: - Private Methods
    
    private func markSentimentGateCompleted() {
        sentimentGateCompleted = true
        userDefaults.set(true, forKey: sentimentGateKey)
    }
    
    private func showAppStoreReview() {
        #if canImport(UIKit)
        Task {
            if let windowScene = await getActiveWindowScene() {
                AppStore.requestReview(in: windowScene)
            }
        }
        #else
        SKStoreReviewController.requestReview()
        #endif
    }
    
    #if canImport(UIKit)
    private func getActiveWindowScene() async -> UIWindowScene? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }
    #endif
}
