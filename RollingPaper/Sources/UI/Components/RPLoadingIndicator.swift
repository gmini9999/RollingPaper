import SwiftUI

public struct RPLoadingIndicator: View {
    public enum Style {
        case spinner
        case linear
    }

    private let style: Style
    private let message: String?

    public init(style: Style = .spinner, message: String? = nil) {
        self.style = style
        self.message = message
    }

    public var body: some View {
        VStack(spacing: .rpSpaceS) {
            indicator
                .accessibilityLabel(message ?? defaultAccessibilityLabel)

            if let message {
                Text(message)
                    .font(.rpBodyM)
                    .foregroundColor(.rpTextPrimary)
            }
        }
        .padding(.rpSpaceM)
    }

    @ViewBuilder
    private var indicator: some View {
        switch style {
        case .spinner:
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.rpPrimary)
        case .linear:
            ProgressView()
                .progressViewStyle(.linear)
                .tint(.rpPrimary)
        }
    }

    private var defaultAccessibilityLabel: String {
        switch style {
        case .spinner:
            return "로딩 중"
        case .linear:
            return "진행 상태"
        }
    }
}
