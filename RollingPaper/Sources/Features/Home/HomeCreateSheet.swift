import SwiftUI

struct HomeCreateSheet: View {
    @Environment(\.interactionFeedbackCenter) private var feedbackCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ObservedObject var viewModel: HomeCreateViewModel
    var onCancel: () -> Void
    var onComplete: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: .rpSpaceL) {
                stepContent
                validationBanner
                Spacer(minLength: 0)
            }
            .padding(.horizontal, .rpSpaceL)
            .padding(.top, .rpSpaceL)
            .padding(.bottom, .rpSpaceXL)
            .background(Color.rpSurfaceAlt.ignoresSafeArea())
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                cancelToolbarItem
                backToolbarItem
                primaryToolbarItem
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(viewModel.showValidationFeedback)
    }

    private var validationBanner: some View {
        Group {
            if let message = viewModel.validationBannerMessage {
                ValidationBanner(message: message)
                    .padding(.horizontal, .rpSpaceS)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .basics:
            ScrollView {
                VStack(alignment: .leading, spacing: .rpSpaceL) {
                    HomeCreateSheetSectionHeader(
                        title: viewModel.currentStep.title,
                        subtitle: viewModel.currentStep.subtitle
                    )

                    PaperFormBasicsSection(
                        draft: $viewModel.draft,
                        titleValidationState: viewModel.titleFieldState,
                        titleValidationMessage: viewModel.titleValidationMessage,
                        showsDeadline: false,
                        showsVisibilityToggle: false
                    )
                }
                .padding(.vertical, .rpSpaceS)
            }
        case .appearance:
            ScrollView {
                VStack(alignment: .leading, spacing: .rpSpaceL) {
                    HomeCreateSheetSectionHeader(
                        title: viewModel.currentStep.title,
                        subtitle: viewModel.currentStep.subtitle
                    )

                    HomeCreateAppearanceStepView(
                        backgrounds: viewModel.backgroundOptions,
                        draft: $viewModel.draftAppearance,
                        showValidation: viewModel.shouldShowAppearanceValidation
                    )
                }
                .padding(.vertical, .rpSpaceS)
            }
        }
    }

    private var cancelToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            if viewModel.currentStep == .basics {
                Button("취소") {
                    feedbackCenter.trigger(haptic: .selection, animation: .subtle, reduceMotion: reduceMotion)
                    onCancel()
                }
                .accessibilityLabel("생성 취소")
            }
        }
    }

    private var backToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if viewModel.canGoBack {
                Button("이전") {
                    feedbackCenter.trigger(haptic: .selection, animation: .subtle, reduceMotion: reduceMotion)
                    viewModel.goBack()
                }
            }
        }
    }

    private var primaryToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(viewModel.primaryActionTitle) {
                viewModel.advance(onInvalid: {
                    feedbackCenter.trigger(haptic: .notification(type: .warning), animation: .subtle, reduceMotion: reduceMotion)
                }, onComplete: onComplete)
            }
            .opacity(viewModel.canAdvance ? 1 : 0.6)
            .accessibilityHint(viewModel.currentStep == .appearance ? "선택한 배경으로 Paper를 생성합니다" : "다음 단계로 이동합니다")
        }
    }
}

private struct ValidationBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .center, spacing: .rpSpaceS) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.rpDanger)

            Text(message)
                .font(.rpBodyM)
                .foregroundStyle(Color.rpDanger)
                .multilineTextAlignment(.leading)

            Spacer(minLength: .rpSpaceS)
        }
        .padding(.horizontal, .rpSpaceM)
        .padding(.vertical, .rpSpaceS)
        .background(Color.rpDanger.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct HomeCreateAppearanceStepView: View {
    @Environment(\.interactionFeedbackCenter) private var feedbackCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let backgrounds: [HomeCreateBackgroundOption]
    @Binding var draft: HomeCreateAppearanceDraft
    let showValidation: Bool

    private var backgroundColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 120), spacing: .rpSpaceM, alignment: .top)]
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: backgroundColumns, spacing: .rpSpaceM) {
                ForEach(backgrounds) { option in
                    backgroundButton(for: option)
                }
            }
            .padding(.vertical, .rpSpaceL)

            if showValidation && draft.selectedBackgroundID == nil {
                validationMessage("배경을 선택해 주세요.")
                    .padding(.horizontal, .rpSpaceS)
            }
        }
        .scrollIndicators(.hidden)
    }

    private func backgroundButton(for option: HomeCreateBackgroundOption) -> some View {
        let isSelected = draft.selectedBackgroundID == option.id

        return Button {
            selectBackground(option)
        } label: {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(backgroundGradient(for: option))
                    .overlay(
                        LinearGradient(
                            colors: [Color.black.opacity(0.0), Color.black.opacity(0.35)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    )

                Text(option.title)
                    .font(.rpBodyM)
                    .foregroundStyle(Color.white)
                    .padding(.rpSpaceM)
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? Color.rpPrimary : Color.white.opacity(0.22), lineWidth: isSelected ? 2 : 1)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.white)
                        .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
                        .padding(.rpSpaceS)
                        .transition(.scale)
                }
            }
            .accessibilityLabel(option.title)
            .accessibilityValue(isSelected ? "선택됨" : "선택 가능")
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
        .buttonStyle(.plain)
    }

    private func backgroundGradient(for option: HomeCreateBackgroundOption?) -> LinearGradient {
        let colors = option?.gradientColors ?? [Color.rpSurface, Color.rpSurface]
        if colors.count == 1, let single = colors.first {
            return LinearGradient(colors: [single, single], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private func selectBackground(_ option: HomeCreateBackgroundOption) {
        guard draft.selectedBackgroundID != option.id else { return }
        draft.selectedBackgroundID = option.id
        feedbackCenter.trigger(haptic: .selection, animation: .subtle, reduceMotion: reduceMotion)
    }

    private func validationMessage(_ message: String) -> some View {
        Text(message)
            .font(.rpCaption)
            .foregroundStyle(Color.rpDanger)
    }
}

private struct HomeCreateSheetSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.rpHeadingM)
                .foregroundStyle(Color.rpTextPrimary)

            Text(subtitle)
                .font(.rpCaption)
                .foregroundStyle(Color.rpTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Home Create Sheet") {
    let provider = InterfaceProvider()
    HomeCreateSheet(viewModel: HomeCreateViewModel(), onCancel: {}, onComplete: {})
        .environmentObject(provider)
        .interface(provider)
}

