import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Handles sentiment gate logic and URL opening functionality
@MainActor
internal final class SentimentGate {
    
    private let configuration: SentimentGateConfiguration
    private let storage: RatingStorage
    
    init(configuration: SentimentGateConfiguration, storage: RatingStorage) {
        self.configuration = configuration
        self.storage = storage
    }
    
    /// Check if sentiment gate should be shown
    func shouldShowSentimentGate() -> Bool {
        return !storage.hasShownSentimentGate
    }
    
    /// Handle positive sentiment response
    func handlePositiveResponse() {
        storage.recordSentimentResponse(positive: true)
    }
    
    /// Handle negative sentiment response
    /// - Parameter openFeedbackURL: Whether to open the feedback URL if configured
    func handleNegativeResponse(openFeedbackURL: Bool = true) {
        storage.recordSentimentResponse(positive: false)
        
        if openFeedbackURL, let feedbackURL = configuration.feedbackURL {
            openFeedbackURLInternal(feedbackURL)
        }
    }
    
    /// Check if user previously indicated they like the app
    func userLikesApp() -> Bool {
        return storage.userLikesApp
    }
    
    // MARK: - Private Methods
    
    private func openFeedbackURLInternal(_ url: URL) {
        if #available(iOS 15.0, macOS 12.0, *) {
            Task {
                await openURL(url)
            }
        } else {
            // For older versions, use synchronous opening
            #if canImport(UIKit)
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
            #endif
        }
    }
    
    private func openURL(_ url: URL) async {
        #if canImport(UIKit)
        if UIApplication.shared.canOpenURL(url) {
            await UIApplication.shared.open(url)
        }
        #endif
    }
}
