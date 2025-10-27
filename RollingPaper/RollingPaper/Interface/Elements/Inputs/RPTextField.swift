import SwiftUI
import UIKit

public struct RPTextField: View {
    private let title: String?
    private let placeholder: String
    @Binding private var text: String
    private let helperText: String?
    private let state: RPFieldState
    private let keyboardType: UIKeyboardType
    private let textContentType: UITextContentType?

    @FocusState private var isFocused: Bool

    public init(_ placeholder: String,
                text: Binding<String>,
                title: String? = nil,
                helperText: String? = nil,
                state: RPFieldState = .normal,
                keyboardType: UIKeyboardType = .default,
                textContentType: UITextContentType? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.title = title
        self.helperText = helperText
        self.state = state
        self.keyboardType = keyboardType
        self.textContentType = textContentType
    }

    public var body: some View {
        RPFormField(title: title,
                    helperText: helperText,
                    state: displayState) {
            TextField(placeholder, text: $text)
                .padding(.horizontal, .rpSpaceM)
                .padding(.vertical, 12)
                .background(displayState.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(displayState.borderColor(isFocused: isFocused), lineWidth: 1)
                )
                .font(.rpBodyM)
                .foregroundColor(displayState.textColor)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .focused($isFocused)
                .disabled(!displayState.allowsInteraction)
                .accessibilityValue(text)
        }
    }

    private var displayState: RPFieldState {
        guard state == .normal else { return state }
        return isFocused ? .focused : .normal
    }
}
