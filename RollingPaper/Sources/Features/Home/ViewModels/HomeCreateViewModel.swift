import Foundation
import SwiftUI

struct HomeCreateBackgroundOption: Identifiable, Equatable {
    let id: String
    let title: String
    let gradientColors: [Color]
    let symbolName: String?
}

enum HomeCreateAppearanceCatalog {
    static let backgrounds: [HomeCreateBackgroundOption] = [
        HomeCreateBackgroundOption(
            id: "sunset-glow",
            title: "선셋 글로우",
            gradientColors: [Color(red: 0.99, green: 0.78, blue: 0.59), Color(red: 0.89, green: 0.47, blue: 0.67)],
            symbolName: "sun.max.fill"
        ),
        HomeCreateBackgroundOption(
            id: "ocean-breeze",
            title: "오션 브리즈",
            gradientColors: [Color(red: 0.31, green: 0.68, blue: 0.94), Color(red: 0.07, green: 0.36, blue: 0.72)],
            symbolName: "waveform.path"
        ),
        HomeCreateBackgroundOption(
            id: "lavender-dream",
            title: "라벤더 드림",
            gradientColors: [Color(red: 0.76, green: 0.69, blue: 0.99), Color(red: 0.59, green: 0.48, blue: 0.86)],
            symbolName: "sparkles"
        ),
        HomeCreateBackgroundOption(
            id: "citrus-pop",
            title: "시트러스 팝",
            gradientColors: [Color(red: 0.99, green: 0.84, blue: 0.51), Color(red: 0.99, green: 0.65, blue: 0.31)],
            symbolName: "sunrise.fill"
        ),
        HomeCreateBackgroundOption(
            id: "forest-haze",
            title: "포레스트 헤이즈",
            gradientColors: [Color(red: 0.45, green: 0.71, blue: 0.64), Color(red: 0.20, green: 0.41, blue: 0.36)],
            symbolName: "leaf.fill"
        ),
        HomeCreateBackgroundOption(
            id: "cloudy-day",
            title: "클라우디 데이",
            gradientColors: [Color(red: 0.94, green: 0.95, blue: 0.98), Color(red: 0.82, green: 0.86, blue: 0.94)],
            symbolName: "cloud.fill"
        )
    ]
}

@MainActor
@Observable
final class HomeCreateViewModel {
    enum Step: Int, CaseIterable {
        case basics
        case appearance

        var title: String {
            switch self {
            case .basics:
                return "기본 정보"
            case .appearance:
                return "배경 설정"
            }
        }

        var subtitle: String {
            switch self {
            case .basics:
                return "Paper를 대표할 제목과 설명을 입력해 주세요."
            case .appearance:
                return "Paper 분위기에 맞는 배경을 선택해 주세요."
            }
        }
    }

    var currentStep: Step = .basics
    var draft: PaperFormDraft = .init()
    var draftAppearance: HomeCreateAppearanceDraft

    var backgroundOptions: [HomeCreateBackgroundOption]
    var showValidationFeedback = false

    var canGoBack: Bool {
        currentStep != .basics
    }

    var primaryActionTitle: String {
        currentStep == .appearance ? "만들기" : "다음"
    }

    var canAdvance: Bool {
        isStepValid(currentStep)
    }

    var navigationTitle: String {
        switch currentStep {
        case .basics:
            return "새 롤링페이퍼"
        case .appearance:
            return draft.trimmedTitle.isEmpty ? "배경 설정" : draft.trimmedTitle
        }
    }

    var shouldShowTitleError: Bool {
        showValidationFeedback && currentStep == .basics && !draft.isTitleValid
    }

    var shouldShowAppearanceValidation: Bool {
        showValidationFeedback && currentStep == .appearance && !isAppearanceValid
    }

    var validationBannerMessage: String? {
        guard showValidationFeedback else { return nil }
        switch currentStep {
        case .basics where !draft.isTitleValid:
            return draft.titleErrorMessage
        case .appearance where !isAppearanceValid:
            return "배경을 선택해 주세요."
        default:
            return nil
        }
    }

    init(backgrounds: [HomeCreateBackgroundOption]? = nil) {
        backgroundOptions = backgrounds ?? HomeCreateAppearanceCatalog.backgrounds
        draftAppearance = HomeCreateAppearanceDraft(selectedBackgroundID: nil)
    }

    func goBack() {
        guard let previous = Step(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = previous
        showValidationFeedback = false
    }

    func advance(onInvalid: () -> Void = {}, onComplete: () -> Void) {
        guard isStepValid(currentStep) else {
            withAnimation(.easeInOut) {
                showValidationFeedback = true
            }
            onInvalid()
            return
        }

        withAnimation(.easeInOut) {
            showValidationFeedback = false
        }

        if currentStep == .appearance {
            onComplete()
        } else {
            moveToNextStep()
        }
    }

    func resetValidation() {
        withAnimation(.easeInOut) {
            showValidationFeedback = false
        }
    }

    func prepareForNewPaper() {
        draft = .init()
        draftAppearance = HomeCreateAppearanceDraft(selectedBackgroundID: nil)
        currentStep = .basics
        resetValidation()
    }

    private func moveToNextStep() {
        guard let next = Step(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = next
    }

    private func isStepValid(_ step: Step) -> Bool {
        switch step {
        case .basics:
            return draft.isTitleValid
        case .appearance:
            return isAppearanceValid
        }
    }

    private var isAppearanceValid: Bool {
        draftAppearance.selectedBackgroundID != nil
    }
}

struct HomeCreateAppearanceDraft: Equatable {
    var selectedBackgroundID: String?
}

