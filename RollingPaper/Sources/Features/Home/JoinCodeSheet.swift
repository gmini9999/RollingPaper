import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct JoinCodeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.interactionFeedbackCenter) private var feedbackCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var codeInput: String = ""
    @State private var fieldState: RPFieldState = .normal
    @State private var isSubmitting = false
    @FocusState private var isTextFieldFocused: Bool

    let recentCodes: [String]
    let onJoin: (String) async throws -> HomePaperSummary
    let onSuccess: (HomePaperSummary) -> Void
    let onDismiss: () -> Void

    private var normalizedCode: String {
        codeInput.uppercased().filter { $0.isLetter || $0.isNumber }
    }

    private var canSubmit: Bool {
        normalizedCode.count == 12 && !isSubmitting
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: .rpSpaceXL) {
                inputSection
                Spacer(minLength: 0)
            }
            .padding(.horizontal, .rpSpaceL)
            .padding(.vertical, .rpSpaceL)
            .background(Color.rpSurfaceAlt.ignoresSafeArea())
            .navigationTitle("참여하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                cancelToolbarItem
                submitToolbarItem
            }
        }
        .onAppear {
            resetState()
            withAnimation(.easeInOut.delay(0.2)) {
                isTextFieldFocused = true
            }
        }
        .onDisappear { onDismiss() }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: .rpSpaceM) {
            RPTextField(
                "예: ABCD-1234-EFGH",
                text: $codeInput,
                title: "참여 코드",
                helperText: nil,
                state: fieldState,
                keyboardType: .asciiCapable,
                textContentType: .oneTimeCode
            )
            .focused($isTextFieldFocused)
            .textInputAutocapitalization(.characters)
            .onChange(of: codeInput) { _, newValue in
                let formatted = formatInput(newValue)
                if formatted != newValue {
                    codeInput = formatted
                }
                updateHelper()
            }
        }
    }

    private var cancelToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("닫기") {
                dismiss()
            }
        }
    }

    private var submitToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("참여하기") {
                Task { await submit() }
            }
            .disabled(!canSubmit || isSubmitting)
        }
    }

    private func formatInput(_ value: String) -> String {
        let normalized = value.uppercased().filter { $0.isLetter || $0.isNumber }
        let limited = String(normalized.prefix(12))
        let chunks = stride(from: 0, to: limited.count, by: 4).map { index -> String in
            let start = limited.index(limited.startIndex, offsetBy: index)
            let end = limited.index(start, offsetBy: 4, limitedBy: limited.endIndex) ?? limited.endIndex
            return String(limited[start..<end])
        }
        return chunks.joined(separator: chunks.count > 1 ? "-" : "")
    }

    private func updateHelper() {
        let remaining = max(0, 12 - normalizedCode.count)
        fieldState = .normal
        if remaining > 0 {
            fieldState = .normal
        }
    }

    private func submit() async {
        guard !isSubmitting else { return }

        guard normalizedCode.count == 12 else {
            withAnimation(.easeInOut) {
                fieldState = .error
            }
            feedbackCenter.trigger(haptic: .notification(type: .error), animation: .subtle, reduceMotion: reduceMotion)
            return
        }

        isSubmitting = true
        fieldState = .normal

        do {
            let summary = try await onJoin(normalizedCode)
            feedbackCenter.trigger(haptic: .notification(type: .success), animation: .subtle, reduceMotion: reduceMotion)
            onSuccess(summary)
            dismiss()
        } catch {
            withAnimation(.easeInOut) {
                fieldState = .error
            }
            feedbackCenter.trigger(haptic: .notification(type: .error), animation: .subtle, reduceMotion: reduceMotion)
        }

        isSubmitting = false
    }

    private func resetState() {
        codeInput = ""
        fieldState = .normal
    }
}
