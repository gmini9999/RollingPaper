import SwiftUI

public struct RPFormField<Content: View>: View {
    private let title: String?
    private let helperText: String?
    private let state: RPFieldState
    private let content: Content

    public init(title: String? = nil,
                helperText: String? = nil,
                state: RPFieldState = .normal,
                @ViewBuilder content: () -> Content) {
        self.title = title
        self.helperText = helperText
        self.state = state
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .rpSpaceXS) {
            if let title, !title.isEmpty {
                Text(title)
                    .font(.rpBodyM)
                    .foregroundColor(.rpTextPrimary)
                    .accessibilityAddTraits(.isStaticText)
            }

            content

            if let helperText, !helperText.isEmpty {
                Text(helperText)
                    .font(.rpBodyM)
                    .foregroundColor(state.helperColor)
                    .accessibilityHint(helperText)
            }
        }
    }
}
