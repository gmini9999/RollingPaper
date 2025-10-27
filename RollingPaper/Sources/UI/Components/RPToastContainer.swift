import SwiftUI

private struct RPToastCenterKey: EnvironmentKey {
    static let defaultValue: RPToastCenter = .shared
}

public extension EnvironmentValues {
    var rpToastCenter: RPToastCenter {
        get { self[RPToastCenterKey.self] }
        set { self[RPToastCenterKey.self] = newValue }
    }
}

public extension View {
    func toastCenter(_ center: RPToastCenter) -> some View {
        environment(\.rpToastCenter, center)
    }
}

public struct RPToastContainer<Content: View>: View {
    @Environment(\.rpToastCenter) private var toastCenter
    @Environment(\.interface) private var interfaceProvider

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .top) {
            content

            if let toast = toastCenter.currentToast {
                toastView(for: toast)
                    .padding(.horizontal, .rpSpaceM)
                    .padding(.top, .rpSpaceXXL)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.rp(.standard, reduceMotion: interfaceProvider.reduceMotion), value: toastCenter.currentToast?.id)
    }

    @ViewBuilder
    private func toastView(for toast: RPToast) -> some View {
        VStack(alignment: .leading, spacing: .rpSpaceXS) {
            if let title = toast.title {
                Text(title)
                    .font(.rpHeadingM)
                    .foregroundColor(toast.style.foregroundColor)
            }

            Text(toast.message)
                .font(.rpBodyM)
                .foregroundColor(toast.style.foregroundColor.opacity(0.92))
                .accessibilityIdentifier("toast_message")

            if let action = toast.action {
                Button(action: {
                    toastCenter.dismiss()
                    action.perform()
                }) {
                    Text(action.title)
                        .font(.rpBodyM)
                        .foregroundColor(toast.style.foregroundColor)
                        .padding(.vertical, .rpSpaceXS)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("toast_action")
            }
        }
        .padding(.rpSpaceM)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(toast.style.backgroundColor.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 18, y: 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel(for: toast))
        .onTapGesture {
            toastCenter.dismiss()
        }
    }

    private func accessibilityLabel(for toast: RPToast) -> String {
        let title = toast.title ?? ""
        if title.isEmpty {
            return toast.message
        }
        return "\(title), \(toast.message)"
    }
}
