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
    public var willShowSentimentGateWhenRequested: Bool {
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
            showSentimentGateAlert()
        } else {
            showAppStoreReview()
        }
    }
    
    /// Reset the sentiment gate state (useful for testing)
    public func resetSentimentGate() {
        userDefaults.removeObject(forKey: sentimentGateKey)
        sentimentGateCompleted = false
    }
    
    // MARK: - Private Methods
    
    private func showSentimentGateAlert() {
        #if canImport(UIKit)
        Task {
            await presentSentimentAlert()
        }
        #else
        // On macOS, show App Store review directly if UIKit is not available
        showAppStoreReview()
        #endif
    }
    
    #if canImport(UIKit)
    private func presentSentimentAlert() async {
        guard let windowScene = await getActiveWindowScene(),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            // Fallback to direct App Store review if we can't present the alert
            showAppStoreReview()
            return
        }
        
        let alert = UIAlertController(
            title: configuration.sentimentQuestion,
            message: nil,
            preferredStyle: .alert
        )
        
        // Positive response action
        let positiveAction = UIAlertAction(
            title: configuration.positiveButtonText,
            style: .default
        ) { [weak self] _ in
            self?.handlePositiveResponse()
        }
        
        // Negative response action
        let negativeAction = UIAlertAction(
            title: configuration.negativeButtonText,
            style: .cancel
        ) { [weak self] _ in
            self?.handleNegativeResponse()
        }
        
        alert.addAction(positiveAction)
        alert.addAction(negativeAction)
        
        // Present the alert
        rootViewController.present(alert, animated: true)
    }
    #endif
    
    private func handlePositiveResponse() {
        markSentimentGateCompleted()
        showAppStoreReview()
    }
    
    private func handleNegativeResponse() {
        markSentimentGateCompleted()
        
        // Open feedback URL if provided
        if let feedbackURL = configuration.feedbackURL {
            #if canImport(UIKit)
            UIApplication.shared.open(feedbackURL)
            #endif
        }
    }
    
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

