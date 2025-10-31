import OSLog
import Foundation

/// Centralized logging for RollingPaper using os_log
/// Provides category-based logging with proper log levels
@MainActor
final class RPLogger {
    // MARK: - Subsystems
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.rollingpaper"
    
    // MARK: - Categories
    enum Category: String {
        case audio = "Audio"
        case navigation = "Navigation"
        case paperKit = "PaperKit"
        case auth = "Auth"
        case network = "Network"
        case ui = "UI"
        case general = "General"
        
        var logger: Logger {
            Logger(subsystem: RPLogger.subsystem, category: rawValue)
        }
    }
    
    // MARK: - Logging Methods
    static func debug(_ message: String, category: Category = .general) {
        category.logger.debug("\(message, privacy: .public)")
    }
    
    static func info(_ message: String, category: Category = .general) {
        category.logger.info("\(message, privacy: .public)")
    }
    
    static func notice(_ message: String, category: Category = .general) {
        category.logger.notice("\(message, privacy: .public)")
    }
    
    static func warning(_ message: String, category: Category = .general) {
        category.logger.warning("\(message, privacy: .public)")
    }
    
    static func error(_ message: String, error: Error? = nil, category: Category = .general) {
        if let error = error {
            category.logger.error("\(message, privacy: .public): \(error.localizedDescription, privacy: .public)")
        } else {
            category.logger.error("\(message, privacy: .public)")
        }
    }
    
    static func fault(_ message: String, category: Category = .general) {
        category.logger.fault("\(message, privacy: .public)")
    }
}

// MARK: - Convenience Extensions
extension RPLogger.Category {
    /// Log debug message for this category
    func debug(_ message: String) {
        RPLogger.debug(message, category: self)
    }
    
    /// Log info message for this category
    func info(_ message: String) {
        RPLogger.info(message, category: self)
    }
    
    /// Log error message for this category
    func error(_ message: String, error: Error? = nil) {
        RPLogger.error(message, error: error, category: self)
    }
}

