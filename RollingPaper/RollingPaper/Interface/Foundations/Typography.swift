import SwiftUI

public struct RPFontStyle {
    public let name: String
    public let size: CGFloat
    public let weight: Font.Weight
    public let relativeTo: Font.TextStyle
}

public enum RPFontToken {
    case headingL
    case headingM
    case bodyL
    case bodyM
    case caption
}

public extension Font {
    static func rp(_ token: RPFontToken) -> Font {
        switch token {
        case .headingL:
            return .custom("SFPro-Semibold", size: 28, relativeTo: .largeTitle)
        case .headingM:
            return .custom("SFPro-Semibold", size: 22, relativeTo: .title2)
        case .bodyL:
            return .custom("SFPro-Regular", size: 17, relativeTo: .body)
        case .bodyM:
            return .custom("SFPro-Regular", size: 15, relativeTo: .callout)
        case .caption:
            return .custom("SFPro-Regular", size: 13, relativeTo: .caption)
        }
    }

    static var rpHeadingL: Font { rp(.headingL) }
    static var rpHeadingM: Font { rp(.headingM) }
    static var rpBodyM: Font { rp(.bodyM) }
    static var rpCaption: Font { rp(.caption) }
}

