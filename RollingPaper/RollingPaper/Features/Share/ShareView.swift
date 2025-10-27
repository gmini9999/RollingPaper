import SwiftUI

struct ShareView: View {
    let paperID: UUID
    @Environment(\.adaptiveLayoutContext) private var layout

    var body: some View {
        VStack(spacing: .rpSpaceM) {
            Text("Share this paper")
                .font(layout.breakpoint == .expanded ? .rpHeadingL : .rpHeadingM)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("ID: \(paperID.uuidString)")
                .font(.rpBodyM)
                .foregroundColor(.rpTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            RPButton("Copy Link") {
                // TODO: implement share sheet
            }
        }
        .adaptiveContentContainer()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.rpSurface)
    }
}

#Preview("Share – Compact") {
    let provider = InterfaceProvider()
    return ShareView(paperID: UUID())
        .environment(\.adaptiveLayoutContext, .fallback)
        .environmentObject(provider)
        .interface(provider)
}

#Preview("Share – Expanded") {
    let provider = InterfaceProvider()
    let expanded = AdaptiveLayoutContext(
        breakpoint: .expanded,
        idiom: .pad,
        isLandscape: true,
        width: 1024,
        height: 768
    )
    return ShareView(paperID: UUID())
        .environment(\.adaptiveLayoutContext, expanded)
        .environmentObject(provider)
        .interface(provider)
}
