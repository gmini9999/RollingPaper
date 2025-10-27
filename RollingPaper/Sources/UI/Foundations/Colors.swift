import SwiftUI
import UIKit

public enum RPColorToken {
    case primary
    case primaryAlt
    case accent
    case danger
    case surface
    case surfaceAlt
    case textPrimary
    case textInverse
    case shadow
}

extension Color {
    public static func rp(_ token: RPColorToken) -> Color {
        Color(UIColor { traitCollection in
            RPColorPalette.color(for: token, style: traitCollection.userInterfaceStyle)
        })
    }

    public static var rpPrimary: Color { rp(.primary) }
    public static var rpPrimaryAlt: Color { rp(.primaryAlt) }
    public static var rpAccent: Color { rp(.accent) }
    public static var rpDanger: Color { rp(.danger) }
    public static var rpTextPrimary: Color { rp(.textPrimary) }
    public static var rpTextInverse: Color { rp(.textInverse) }
    public static var rpSurface: Color { rp(.surface) }
    public static var rpSurfaceAlt: Color { rp(.surfaceAlt) }
    public static var rpShadow: Color { rp(.shadow) }

    public static var rpTextSecondary: Color {
        Color(UIColor { traitCollection in
            let base = RPColorPalette.color(for: .textPrimary, style: traitCollection.userInterfaceStyle)
            let alpha: CGFloat = traitCollection.userInterfaceStyle == .dark ? 0.82 : 0.72
            return base.withAlphaComponent(alpha)
        })
    }
}

private enum RPColorPalette {
    private static let fallback = UIColor(hex: "#CCCCCC")!

    private static let light: [RPColorToken: UIColor] = [
        .primary: UIColor(hex: "#5B4BFF")!,
        .primaryAlt: UIColor(hex: "#4338CA")!,
        .accent: UIColor(hex: "#22C55E")!,
        .danger: UIColor(hex: "#EF4444")!,
        .surface: UIColor(hex: "#FFFFFF")!,
        .surfaceAlt: UIColor(hex: "#F5F5FA")!,
        .textPrimary: UIColor(hex: "#1F2933")!,
        .textInverse: UIColor(hex: "#FFFFFF")!,
        .shadow: UIColor(hex: "#0F172A")!
    ]

    private static let dark: [RPColorToken: UIColor] = [
        .primary: UIColor(hex: "#8B7BFF")!,
        .primaryAlt: UIColor(hex: "#5E4DF2")!,
        .accent: UIColor(hex: "#34D399")!,
        .danger: UIColor(hex: "#F87171")!,
        .surface: UIColor(hex: "#101623")!,
        .surfaceAlt: UIColor(hex: "#1B2333")!,
        .textPrimary: UIColor(hex: "#E8ECF5")!,
        .textInverse: UIColor(hex: "#05070C")!,
        .shadow: UIColor(hex: "#000000")!
    ]

    static func color(for token: RPColorToken, style: UIUserInterfaceStyle) -> UIColor {
        switch style {
        case .dark:
            return dark[token] ?? fallback
        default:
            return light[token] ?? fallback
        }
    }
}

private extension UIColor {
    convenience init?(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard Scanner(string: sanitized).scanHexInt64(&int) else { return nil }

        let r, g, b: UInt64
        switch sanitized.count {
        case 6:
            r = (int & 0xFF0000) >> 16
            g = (int & 0x00FF00) >> 8
            b = int & 0x0000FF
        default:
            return nil
        }

        self.init(red: CGFloat(r) / 255,
                  green: CGFloat(g) / 255,
                  blue: CGFloat(b) / 255,
                  alpha: 1)
    }
}