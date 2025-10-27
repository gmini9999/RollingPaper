import SwiftUI

public enum RPSpaceToken: CGFloat {
    case xxs = 4
    case xs = 8
    case s = 12
    case m = 16
    case l = 24
    case xl = 32
    case xxl = 48
}

public extension CGFloat {
    static var rpSpaceXXS: CGFloat { RPSpaceToken.xxs.rawValue }
    static var rpSpaceXS: CGFloat { RPSpaceToken.xs.rawValue }
    static var rpSpaceS: CGFloat { RPSpaceToken.s.rawValue }
    static var rpSpaceM: CGFloat { RPSpaceToken.m.rawValue }
    static var rpSpaceL: CGFloat { RPSpaceToken.l.rawValue }
    static var rpSpaceXL: CGFloat { RPSpaceToken.xl.rawValue }
    static var rpSpaceXXL: CGFloat { RPSpaceToken.xxl.rawValue }
}

