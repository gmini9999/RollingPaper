import SwiftUI

public struct RPCardStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(.rpSpaceM)
            .background(Color.rpSurfaceAlt)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.rp(.shadowColor, scheme: .current).opacity(0.15), radius: 12, y: 6)
    }
}

public extension View {
    func rpCardStyle() -> some View {
        modifier(RPCardStyle())
    }
}

