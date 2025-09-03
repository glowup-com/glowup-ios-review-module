import Foundation

/// Configuration for the rating kit
public struct Configuration {
    /// Whether to show a sentiment gate before the app store review
    public let enableSentimentGate: Bool
    
    /// The positive question to ask in the sentiment gate
    public let sentimentQuestion: String
    
    /// The positive button text
    public let positiveButtonText: String
    
    /// The negative button text  
    public let negativeButtonText: String
    
    /// Optional URL to redirect users who give negative feedback
    public let feedbackURL: URL?
    
    public init(
        enableSentimentGate: Bool = true,
        sentimentQuestion: String = "Are you enjoying this app?",
        positiveButtonText: String = "Yes!",
        negativeButtonText: String = "Not really",
        feedbackURL: URL? = nil
    ) {
        self.enableSentimentGate = enableSentimentGate
        self.sentimentQuestion = sentimentQuestion
        self.positiveButtonText = positiveButtonText
        self.negativeButtonText = negativeButtonText
        self.feedbackURL = feedbackURL
    }
}
