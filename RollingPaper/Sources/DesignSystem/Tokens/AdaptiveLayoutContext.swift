import SwiftUI

struct AdaptiveLayoutContext: Equatable {
    enum Breakpoint: Equatable {
        case compact
        case medium
        case expanded
    }

    let breakpoint: Breakpoint
    let idiom: UIUserInterfaceIdiom
    let isLandscape: Bool
    let width: CGFloat
    let height: CGFloat

    var isPad: Bool { idiom == .pad }
    var isPhone: Bool { idiom == .phone }

    static let fallback = AdaptiveLayoutContext(
        breakpoint: .compact,
        idiom: UIDevice.current.userInterfaceIdiom,
        isLandscape: false,
        width: 375,
        height: 812
    )

    static func resolve(
        proxy: GeometryProxy,
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass?
    ) -> AdaptiveLayoutContext {
        let size = proxy.size
        let width = size.width
        let height = size.height
        let isLandscape = width > height
        let idiom = UIDevice.current.userInterfaceIdiom

        let breakpoint: Breakpoint
        switch width {
        case ..<AppConstants.Breakpoint.medium:
            breakpoint = .compact
        case AppConstants.Breakpoint.medium..<AppConstants.Breakpoint.expanded:
            breakpoint = .medium
        default:
            breakpoint = .expanded
        }

        return AdaptiveLayoutContext(
            breakpoint: breakpoint,
            idiom: idiom,
            isLandscape: isLandscape,
            width: width,
            height: height
        )
    }
}

private struct AdaptiveLayoutContextKey: EnvironmentKey {
    static let defaultValue: AdaptiveLayoutContext = .fallback
}

extension EnvironmentValues {
    var adaptiveLayoutContext: AdaptiveLayoutContext {
        get { self[AdaptiveLayoutContextKey.self] }
        set { self[AdaptiveLayoutContextKey.self] = newValue }
    }
}

struct AdaptiveContentContainerModifier: ViewModifier {
    @Environment(\.adaptiveLayoutContext) private var layout

    func body(content: Content) -> some View {
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
        let maxWidth: CGFloat?

        switch layout.breakpoint {
        case .compact:
            horizontalPadding = AppConstants.ContentPadding.Compact.horizontal
            verticalPadding = AppConstants.ContentPadding.Compact.vertical
            maxWidth = nil
        case .medium:
            horizontalPadding = AppConstants.ContentPadding.Medium.horizontal
            verticalPadding = AppConstants.ContentPadding.Medium.vertical
            maxWidth = AppConstants.MaxWidth.medium
        case .expanded:
            horizontalPadding = AppConstants.ContentPadding.Expanded.horizontal
            verticalPadding = AppConstants.ContentPadding.Expanded.vertical
            maxWidth = AppConstants.MaxWidth.expanded
        }

        return content
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: maxWidth, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}


