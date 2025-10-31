import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct JoinCodeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.interactionFeedbackCenter) private var feedbackCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var codeInput: String = ""
    @State private var hasError = false
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
            VStack(spacing: 32) {
                inputSection
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
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
        VStack(alignment: .leading, spacing: 12) {
            Text("참여 코드")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("예: ABCD-1234-EFGH", text: $codeInput)
                .keyboardType(.asciiCapable)
                .textContentType(.oneTimeCode)
                .textInputAutocapitalization(.characters)
                .focused($isTextFieldFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(hasError ? Color.red : Color.black.opacity(0.12), lineWidth: hasError ? 1.5 : 1)
                )
                .onChange(of: codeInput) { _, newValue in
                    let formatted = formatInput(newValue)
                    if formatted != newValue {
                        codeInput = formatted
                    }
                    hasError = false
                }

            if hasError {
                Text("올바른 12자리 코드를 입력해 주세요.")
                    .font(.caption)
                    .foregroundStyle(.red)
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

    private func submit() async {
        guard !isSubmitting else { return }

        guard normalizedCode.count == 12 else {
            withAnimation(.easeInOut) {
                hasError = true
            }
            feedbackCenter.trigger(haptic: .notification(type: .error), animation: .subtle, reduceMotion: reduceMotion)
            return
        }

        isSubmitting = true
        hasError = false

        do {
            let summary = try await onJoin(normalizedCode)
            feedbackCenter.trigger(haptic: .notification(type: .success), animation: .subtle, reduceMotion: reduceMotion)
            onSuccess(summary)
            dismiss()
        } catch {
            withAnimation(.easeInOut) {
                hasError = true
            }
            feedbackCenter.trigger(haptic: .notification(type: .error), animation: .subtle, reduceMotion: reduceMotion)
        }

        isSubmitting = false
    }

    private func resetState() {
        codeInput = ""
        hasError = false
    }
}
