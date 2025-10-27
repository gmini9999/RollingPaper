import SwiftUI

public struct RPTextArea: View {
    private let title: String?
    private let placeholder: String
    @Binding private var text: String
    private let helperText: String?
    private let state: RPFieldState
    private let minimumHeight: CGFloat

    @FocusState private var isFocused: Bool

    public init(_ placeholder: String,
                text: Binding<String>,
                title: String? = nil,
                helperText: String? = nil,
                state: RPFieldState = .normal,
                minimumHeight: CGFloat = 120) {
        self.placeholder = placeholder
        self._text = text
        self.title = title
        self.helperText = helperText
        self.state = state
        self.minimumHeight = minimumHeight
    }

    public var body: some View {
        RPFormField(title: title,
                    helperText: helperText,
                    state: displayState) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .frame(minHeight: minimumHeight)
                    .padding(.horizontal, .rpSpaceM - 2)
                    .padding(.vertical, 10)
                    .background(displayState.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(displayState.borderColor(isFocused: isFocused), lineWidth: 1)
                    )
                    .font(.rpBodyM)
                    .foregroundColor(displayState.textColor)
                    .focused($isFocused)
                    .disabled(!displayState.allowsInteraction)
                    .accessibilityValue(text)

                if text.isEmpty {
                    Text(placeholder)
                        .font(.rpBodyM)
                        .foregroundColor(Color.rpTextPrimary.opacity(0.4))
                        .padding(.horizontal, .rpSpaceM)
                        .padding(.vertical, 14)
                        .accessibilityHidden(true)
                }
            }
        }
    }

    private var displayState: RPFieldState {
        guard state == .normal else { return state }
        return isFocused ? .focused : .normal
    }
}
