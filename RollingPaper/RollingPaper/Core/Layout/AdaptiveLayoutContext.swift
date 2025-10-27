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
        case ..<600:
            breakpoint = .compact
        case 600..<900:
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

    var columnVisibilityPreference: NavigationSplitViewVisibility {
        switch breakpoint {
        case .compact:
            return .detailOnly
        case .medium:
            return .doubleColumn
        case .expanded:
            return .all
        }
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

private struct AdaptiveContentContainerModifier: ViewModifier {
    @Environment(\.adaptiveLayoutContext) private var layout

    func body(content: Content) -> some View {
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
        let maxWidth: CGFloat?

        switch layout.breakpoint {
        case .compact:
            horizontalPadding = 16
            verticalPadding = 20
            maxWidth = nil
        case .medium:
            horizontalPadding = 24
            verticalPadding = 24
            maxWidth = 720
        case .expanded:
            horizontalPadding = 32
            verticalPadding = 32
            maxWidth = 960
        }

        return content
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: maxWidth, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

extension View {
    func adaptiveContentContainer() -> some View {
        modifier(AdaptiveContentContainerModifier())
    }
}


