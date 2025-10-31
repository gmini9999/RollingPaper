import SwiftUI

// MARK: - Design Tokens
/// Semantic design tokens for the RollingPaper app
/// Built on top of AppConstants for a consistent design language

extension View {
    /// Apply adaptive content container padding based on layout context
    func adaptiveContentContainer() -> some View {
        modifier(AdaptiveContentContainerModifier())
    }
}

// MARK: - Typography Tokens
enum Typography {
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title = Font.title.weight(.semibold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.semibold)
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let caption2 = Font.caption2
}

// MARK: - Shadow Tokens
enum ShadowTokens {
    static let small = (color: Color.black.opacity(0.1), radius: 2.0, x: 0.0, y: 1.0)
    static let medium = (color: Color.black.opacity(0.15), radius: 4.0, x: 0.0, y: 2.0)
    static let large = (color: Color.black.opacity(0.2), radius: 8.0, x: 0.0, y: 4.0)
}

// MARK: - Opacity Tokens
enum OpacityTokens {
    static let subtle: Double = 0.12
    static let light: Double = 0.25
    static let medium: Double = 0.5
    static let strong: Double = 0.75
}

