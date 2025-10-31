import CoreGraphics
import Foundation

// MARK: - App Constants
/// Centralized constants for the RollingPaper app
/// Prevents hard-coding and ensures consistency across the codebase

enum AppConstants {
    // MARK: - Layout Breakpoints
    enum Breakpoint {
        /// Width threshold for medium breakpoint
        static let medium: CGFloat = 600
        /// Width threshold for expanded breakpoint
        static let expanded: CGFloat = 900
    }
    
    // MARK: - Spacing
    enum Spacing {
        /// Extra small spacing: 4pt
        static let xs: CGFloat = 4
        /// Small spacing: 8pt
        static let s: CGFloat = 8
        /// Medium spacing: 12pt
        static let m: CGFloat = 12
        /// Large spacing: 16pt
        static let l: CGFloat = 16
        /// Extra large spacing: 20pt
        static let xl: CGFloat = 20
        /// XX large spacing: 24pt
        static let xxl: CGFloat = 24
        /// XXX large spacing: 32pt
        static let xxxl: CGFloat = 32
    }
    
    // MARK: - Content Padding
    enum ContentPadding {
        /// Compact: 16pt horizontal, 20pt vertical
        enum Compact {
            static let horizontal: CGFloat = 16
            static let vertical: CGFloat = 20
        }
        /// Medium: 24pt both
        enum Medium {
            static let horizontal: CGFloat = 24
            static let vertical: CGFloat = 24
        }
        /// Expanded: 32pt both
        enum Expanded {
            static let horizontal: CGFloat = 32
            static let vertical: CGFloat = 32
        }
    }
    
    // MARK: - Max Widths
    enum MaxWidth {
        /// Maximum width for medium breakpoint content
        static let medium: CGFloat = 720
        /// Maximum width for expanded breakpoint content
        static let expanded: CGFloat = 960
        /// Maximum width for supplementary column (iPad)
        static let supplementaryColumn: CGFloat = 360
        /// Maximum width for buttons in empty states
        static let button: CGFloat = 280
        /// Maximum width for text in empty states
        static let text: CGFloat = 420
        /// Minimum grid item width
        static let gridItemMin: CGFloat = 320
        /// Maximum grid item width
        static let gridItemMax: CGFloat = 420
    }
    
    // MARK: - Corner Radius
    enum CornerRadius {
        /// Small corner radius: 8pt
        static let s: CGFloat = 8
        /// Medium corner radius: 12pt
        static let m: CGFloat = 12
        /// Large corner radius: 16pt
        static let l: CGFloat = 16
        /// Extra large corner radius: 20pt
        static let xl: CGFloat = 20
        /// Extra extra large corner radius: 32pt
        static let xxl: CGFloat = 32
    }
    
    // MARK: - Icon Sizes
    enum IconSize {
        /// Small icon: 16pt
        static let s: CGFloat = 16
        /// Medium icon: 18pt
        static let m: CGFloat = 18
        /// Large icon: 24pt
        static let l: CGFloat = 24
        /// Extra large icon: 32pt
        static let xl: CGFloat = 32
        /// Empty state icon: 48pt
        static let emptyState: CGFloat = 48
        /// Empty state background: 140pt
        static let emptyStateBackground: CGFloat = 140
    }
    
    // MARK: - Grid Spacing
    enum Grid {
        /// Standard grid spacing
        static let spacing: CGFloat = 28
    }
    
    // MARK: - Timeouts
    enum Timeout {
        /// Default auth timeout in seconds
        static let auth: TimeInterval = 8
        /// Network request timeout in seconds
        static let network: TimeInterval = 30
    }
    
    // MARK: - Animation Durations
    enum AnimationDuration {
        /// Fast animation: 0.2s
        static let fast: TimeInterval = 0.2
        /// Standard animation: 0.3s
        static let standard: TimeInterval = 0.3
        /// Slow animation: 0.5s
        static let slow: TimeInterval = 0.5
    }
    
    // MARK: - Mock Delays (for development)
    enum MockDelay {
        /// Short delay: 400ms
        static let short: UInt64 = 400_000_000
        /// Medium delay: 450ms
        static let medium: UInt64 = 450_000_000
        /// Long delay: 1s
        static let long: UInt64 = 1_000_000_000
    }
    
    // MARK: - Storage Keys
    enum StorageKey {
        /// Key for storing auth session
        static let authSession = "auth.session"
        /// Key prefix for user preferences
        static let userPreferences = "user.preferences"
    }
    
    // MARK: - Join Code
    enum JoinCode {
        /// Expected length of join code (without separators)
        static let length: Int = 12
        /// Chunk size for formatting join code
        static let chunkSize: Int = 4
        /// Maximum number of recent join codes to store
        static let maxRecent: Int = 5
    }
    
    // MARK: - Pagination
    enum Pagination {
        /// Default page size for list pagination
        static let pageSize: Int = 20
        /// Threshold for triggering load more (items from end)
        static let loadMoreThreshold: Int = 2
    }
}

// MARK: - Convenience Extensions
extension CGFloat {
    /// Spacing token shortcuts
    static let rpSpaceXS = AppConstants.Spacing.xs
    static let rpSpaceS = AppConstants.Spacing.s
    static let rpSpaceM = AppConstants.Spacing.m
    static let rpSpaceL = AppConstants.Spacing.l
    static let rpSpaceXL = AppConstants.Spacing.xl
    static let rpSpaceXXL = AppConstants.Spacing.xxl
    static let rpSpaceXXXL = AppConstants.Spacing.xxxl
    
    /// Corner radius shortcuts
    static let rpCornerS = AppConstants.CornerRadius.s
    static let rpCornerM = AppConstants.CornerRadius.m
    static let rpCornerL = AppConstants.CornerRadius.l
    static let rpCornerXL = AppConstants.CornerRadius.xl
    static let rpCornerXXL = AppConstants.CornerRadius.xxl
}

