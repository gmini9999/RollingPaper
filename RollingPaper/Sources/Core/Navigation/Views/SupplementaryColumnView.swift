import SwiftUI

/// Supplementary column shown alongside the primary navigation stack on iPad.
struct AppNavigationSupplementaryColumnView: View {
    let context: AdaptiveLayoutContext
    let paperRoute: PaperRoute?
    var onOpenShare: (UUID) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(L10n.Navigation.Supplementary.layoutOverviewTitle)
                    .font(.title3.weight(.semibold))

                routeSummary

                Divider()

                Text(L10n.Navigation.Supplementary.deviceContextTitle)
                    .font(.title3.weight(.semibold))
                Text(deviceSummary)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
        }
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.regularMaterial)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 24, y: 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
    }

    @ViewBuilder
    private var routeSummary: some View {
        switch paperRoute {
        case .detail(let id):
            Text(L10n.Navigation.Supplementary.editingTitle(String(id.uuidString.prefix(6))))
                .font(.title3.weight(.semibold))
            Text(L10n.Navigation.Supplementary.layoutOverviewEditingDescription)
                .font(.body)
                .foregroundStyle(.secondary)
            Button(L10n.Navigation.Supplementary.openShare) {
                onOpenShare(id)
            }
            .buttonStyle(.borderedProminent)
        case .share(let id):
            Text(L10n.Navigation.Supplementary.sharingTitle(String(id.uuidString.prefix(6))))
                .font(.title3.weight(.semibold))
            Text(L10n.Navigation.Supplementary.layoutOverviewSharingDescription)
                .font(.body)
                .foregroundStyle(.secondary)
        case .none:
            Text(L10n.Navigation.Supplementary.layoutOverviewDefaultDescription)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var deviceSummary: String {
        L10n.Navigation.Supplementary.deviceSummary(
            breakpoint: localizedBreakpoint,
            device: localizedDevice,
            width: Int(context.width),
            height: Int(context.height),
            orientation: localizedOrientation
        )
    }

    private var localizedBreakpoint: String {
        switch context.breakpoint {
        case .compact:
            return L10n.Navigation.Supplementary.breakpointCompact
        case .medium:
            return L10n.Navigation.Supplementary.breakpointMedium
        case .expanded:
            return L10n.Navigation.Supplementary.breakpointExpanded
        }
    }

    private var localizedDevice: String {
        context.isPad ? L10n.Navigation.Supplementary.deviceIPad : L10n.Navigation.Supplementary.deviceIPhone
    }

    private var localizedOrientation: String {
        context.isLandscape ? L10n.Navigation.Supplementary.orientationLandscape : L10n.Navigation.Supplementary.orientationPortrait
    }
}

