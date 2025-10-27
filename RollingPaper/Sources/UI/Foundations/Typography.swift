import SwiftUI

public enum RPFontToken {
    case headingL
    case headingM
    case bodyM
    case caption
}

public extension Font {
    static func rp(_ token: RPFontToken) -> Font {
        switch token {
        case .headingL:
            return .system(size: 28, weight: .semibold, design: .default)
        case .headingM:
            return .system(size: 22, weight: .semibold, design: .default)
        case .bodyM:
            return .system(size: 15, weight: .regular, design: .default)
        case .caption:
            return .system(size: 13, weight: .regular, design: .default)
        }
    }

    static var rpHeadingL: Font { rp(.headingL) }
    static var rpHeadingM: Font { rp(.headingM) }
    static var rpBodyM: Font { rp(.bodyM) }
    static var rpCaption: Font { rp(.caption) }
}

