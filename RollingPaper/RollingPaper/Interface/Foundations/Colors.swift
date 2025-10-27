import SwiftUI
import UIKit

public enum RPColorToken: String {
    case primary = "rpColorPrimary"
    case primaryAlt = "rpColorPrimaryAlt"
    case accent = "rpColorAccent"
    case danger = "rpColorDanger"
    case surface = "rpColorSurface"
    case surfaceAlt = "rpColorSurfaceAlt"
    case textPrimary = "rpColorTextPrimary"
    case textInverse = "rpColorTextInverse"
    case shadowColor = "rpShadowLevel2"
}

extension Color {
    static func rp(_ token: RPColorToken, scheme: ColorScheme) -> Color {
        let key = tokenKey(token, scheme: scheme)
        let hex: String = TokenStore.shared.value(for: key) ?? "#CCCCCC"
        return Color(hex: hex)
    }

    private static func tokenKey(_ token: RPColorToken, scheme: ColorScheme) -> String {
        switch scheme {
        case .dark:
            return "\(token.rawValue)Dark"
        default:
            return token.rawValue
        }
    }

    static var rpPrimary: Color { rp(.primary, scheme: .current) }
    static var rpPrimaryAlt: Color { rp(.primaryAlt, scheme: .current) }
    static var rpAccent: Color { rp(.accent, scheme: .current) }
    static var rpDanger: Color { rp(.danger, scheme: .current) }
    static var rpTextPrimary: Color { rp(.textPrimary, scheme: .current) }
    static var rpTextInverse: Color { rp(.textInverse, scheme: .current) }
    static var rpSurface: Color { rp(.surface, scheme: .current) }
    static var rpSurfaceAlt: Color { rp(.surfaceAlt, scheme: .current) }
}

extension ColorScheme {
    static var current: ColorScheme {
        UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 1)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }
}