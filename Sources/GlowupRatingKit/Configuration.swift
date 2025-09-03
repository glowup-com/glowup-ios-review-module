import Foundation

/// Configuration for the rating system
public struct Configuration {
    /// Minimum number of app sessions required before showing rating prompt
    public let minimumAppSessions: Int
    
    /// Minimum number of successful flows required before showing rating prompt
    public let minimumSuccessFlows: Int
    
    /// Optional sentiment gate configuration to check user satisfaction first
    public let sentimentGateConfiguration: SentimentGateConfiguration?
    
    public init(
        minimumAppSessions: Int,
        minimumSuccessFlows: Int,
        sentimentGateConfiguration: SentimentGateConfiguration? = nil
    ) {
        self.minimumAppSessions = minimumAppSessions
        self.minimumSuccessFlows = minimumSuccessFlows
        self.sentimentGateConfiguration = sentimentGateConfiguration
    }
}

/// Configuration for sentiment gate (pre-rating user satisfaction check)
public struct SentimentGateConfiguration {
    /// Title for the sentiment gate dialog
    public let title: String
    
    /// Message asking if user likes the app
    public let message: String
    
    /// Text for positive response button
    public let positiveButtonText: String
    
    /// Text for negative response button
    public let negativeButtonText: String
    
    /// Optional feedback URL for negative responses
    public let feedbackURL: URL?
    
    public init(
        title: String = "Enjoying the app?",
        message: String = "Are you enjoying using this app?",
        positiveButtonText: String = "Yes!",
        negativeButtonText: String = "Not really",
        feedbackURL: URL? = nil
    ) {
        self.title = title
        self.message = message
        self.positiveButtonText = positiveButtonText
        self.negativeButtonText = negativeButtonText
        self.feedbackURL = feedbackURL
    }
}


