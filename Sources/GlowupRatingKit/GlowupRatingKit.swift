import Foundation

/// GlowupRatingKit - A simple Swift package for handling app store reviews with optional sentiment gate
///
/// This package provides a streamlined approach to requesting app store reviews with an optional
/// sentiment gate that filters users before showing the native iOS review prompt.
///
/// ## Features
/// - Optional sentiment gate to filter positive users
/// - SwiftUI Observable support for reactive UI updates
/// - Simple state management with `needsSentimentGate` property
/// - Automatic redirect to feedback URL for negative responses
/// - Persistent storage of sentiment gate completion
///
/// ## Basic Usage
/// ```swift
/// import GlowupRatingKit
/// 
/// // Create configuration
/// let config = Configuration(
///     enableSentimentGate: true,
///     sentimentQuestion: "Are you enjoying this app?",
///     feedbackURL: URL(string: "https://example.com/feedback")
/// )
/// 
/// // Create rating manager
/// @State private var ratingManager = RatingManager(configuration: config)
/// 
/// // In your SwiftUI view
/// if ratingManager.needsSentimentGate {
///     // Show your sentiment gate UI
/// }
/// 
/// // Request rating
/// ratingManager.requestRating()
/// 
/// // Handle responses
/// ratingManager.handlePositiveResponse() // Shows App Store review
/// ratingManager.handleNegativeResponse() // Opens feedback URL if configured
/// ```

public struct GlowupRatingKit {
    /// The current version of the GlowupRatingKit package
    public static let version = "1.0.0"
    
    /// Private initializer to prevent instantiation
    private init() {}
}
