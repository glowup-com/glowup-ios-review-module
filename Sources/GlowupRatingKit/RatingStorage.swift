import Foundation

/// Internal storage manager for rating-related data persistence
internal final class RatingStorage {
    
    private let userDefaults: UserDefaults
    
    // Keys for UserDefaults storage
    private enum StorageKeys {
        static let appSessionCount = "com.glowup.RatingKit.appSessionCount"
        static let successFlowCount = "com.glowup.RatingKit.successFlowCount"
        static let lastRatingRequestDate = "com.glowup.RatingKit.lastRatingRequestDate"
        static let hasShownSentimentGate = "com.glowup.RatingKit.hasShownSentimentGate"
        static let userLikesApp = "com.glowup.RatingKit.userLikesApp"
    }
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - App Session Management
    
    var appSessionCount: Int {
        get { userDefaults.integer(forKey: StorageKeys.appSessionCount) }
        set { userDefaults.set(newValue, forKey: StorageKeys.appSessionCount) }
    }
    
    func incrementAppSessionCount() {
        appSessionCount += 1
    }
    
    // MARK: - Success Flow Management
    
    var successFlowCount: Int {
        get { userDefaults.integer(forKey: StorageKeys.successFlowCount) }
        set { userDefaults.set(newValue, forKey: StorageKeys.successFlowCount) }
    }
    
    func incrementSuccessFlowCount() {
        successFlowCount += 1
    }
    
    // MARK: - Rating Request Management
    
    var lastRatingRequestDate: Date? {
        get { userDefaults.object(forKey: StorageKeys.lastRatingRequestDate) as? Date }
        set { userDefaults.set(newValue, forKey: StorageKeys.lastRatingRequestDate) }
    }
    
    func recordRatingRequest() {
        lastRatingRequestDate = Date()
    }
    
    // MARK: - Sentiment Gate Management
    
    var hasShownSentimentGate: Bool {
        get { userDefaults.bool(forKey: StorageKeys.hasShownSentimentGate) }
        set { userDefaults.set(newValue, forKey: StorageKeys.hasShownSentimentGate) }
    }
    
    var userLikesApp: Bool {
        get { userDefaults.bool(forKey: StorageKeys.userLikesApp) }
        set { userDefaults.set(newValue, forKey: StorageKeys.userLikesApp) }
    }
    
    func recordSentimentResponse(positive: Bool) {
        hasShownSentimentGate = true
        userLikesApp = positive
    }
    
    // MARK: - Statistics
    
    func getStatistics() -> (appSessions: Int, successFlows: Int, lastRatingDate: Date?) {
        return (appSessionCount, successFlowCount, lastRatingRequestDate)
    }
    
    // MARK: - Data Management
    
    func resetAllData() {
        userDefaults.removeObject(forKey: StorageKeys.appSessionCount)
        userDefaults.removeObject(forKey: StorageKeys.successFlowCount)
        userDefaults.removeObject(forKey: StorageKeys.lastRatingRequestDate)
        userDefaults.removeObject(forKey: StorageKeys.hasShownSentimentGate)
        userDefaults.removeObject(forKey: StorageKeys.userLikesApp)
    }
}


