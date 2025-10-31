import SwiftUI

private enum HomeViewMetrics {
    static let sectionSpacing: CGFloat = 32
    static let gridSpacing: CGFloat = 28
    static let contentPadding: CGFloat = 24
    static let emptyStateSpacing: CGFloat = 32
    static let emptyStatePadding: CGFloat = 32
    static let toolbarIconFont = Font.title3.weight(.semibold)
}

struct HomeView: View {
    @Environment(\.interactionFeedbackCenter) private var feedbackCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var navigator: AppNavigator

    @StateObject private var viewModel: HomeViewModel
    @StateObject private var createViewModel = HomeCreateViewModel()

    private let onOpenPaper: ((UUID) -> Void)?

    init(viewModel: HomeViewModel? = nil,
         onOpenPaper: ((UUID) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? HomeViewModel())
        self.onOpenPaper = onOpenPaper
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 320, maximum: 420), spacing: HomeViewMetrics.gridSpacing, alignment: .top)]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: HomeViewMetrics.sectionSpacing) {
                if viewModel.hasPapers {
                    cardGallery
                } else {
                    HomeEmptyStateView(onTapCreate: handleCreateTapped)
                        .padding(.horizontal, HomeViewMetrics.contentPadding)
                }
            }
            .padding(.vertical, HomeViewMetrics.sectionSpacing)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("RollingPaper")
                        .font(.title3.weight(.semibold))
                    Text("함께 만드는 메시지")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    feedbackCenter.trigger(
                        haptic: .selection,
                        animation: .subtle,
                        reduceMotion: reduceMotion
                    )
                    navigator.present(.joinPaper)
                } label: {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(HomeViewMetrics.toolbarIconFont)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tint)
                .accessibilityLabel("참여하기")

                Button(action: handleCreateTapped) {
                    Image(systemName: "plus.circle.fill")
                        .font(HomeViewMetrics.toolbarIconFont)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tint)
                .accessibilityLabel("새로 만들기")
            }
        }
        .toolbarBackground(.regularMaterial, for: .navigationBar)
        .sheet(item: $navigator.activeModal, onDismiss: navigator.dismissModal) { modal in
            modalContent(for: modal)
        }
    }

    private var cardGallery: some View {
        LazyVGrid(columns: columns, spacing: HomeViewMetrics.sectionSpacing) {
            ForEach(viewModel.summaries) { summary in
                Button {
                    handleSelectPaper(summary.id)
                } label: {
                    HomePaperCard(summary: summary)
                }
                .buttonStyle(.plain)
                .onAppear { viewModel.loadMoreIfNeeded(current: summary) }
            }
        }
        .padding(.horizontal, HomeViewMetrics.contentPadding)
    }

    private func handleCreateTapped() {
        feedbackCenter.trigger(
            haptic: .impact(style: .medium),
            animation: .tap,
            reduceMotion: reduceMotion
        )
        createViewModel.prepareForNewPaper()
        navigator.present(.createPaper)
    }

    private func handleSelectPaper(_ id: UUID) {
        feedbackCenter.trigger(
            haptic: .selection,
            animation: .subtle,
            reduceMotion: reduceMotion
        )
        onOpenPaper?(id)
    }

    @ViewBuilder
    private func modalContent(for modal: ModalDestination) -> some View {
        switch modal {
        case .createPaper:
            HomeCreateSheet(
                viewModel: createViewModel,
                onCancel: navigator.dismissModal,
                onComplete: navigator.dismissModal
            )
            .presentationDetents([.medium, .large])
            .onAppear { createViewModel.prepareForNewPaper() }
        case .joinPaper:
            JoinCodeSheet(
                recentCodes: viewModel.recentJoinCodes,
                onJoin: { code in try await viewModel.joinPaper(with: code) },
                onSuccess: { summary in
                    navigator.dismissModal()
                    onOpenPaper?(summary.id)
                },
                onDismiss: navigator.dismissModal
            )
            .presentationDetents([.medium, .large])
        }
    }
}

private struct HomeEmptyStateView: View {
    let onTapCreate: () -> Void

    var body: some View {
        VStack(spacing: HomeViewMetrics.emptyStateSpacing) {
            icon

            VStack(spacing: 12) {
                Text("아직 생성된 롤링페이퍼가 없어요")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                Text("새 롤링페이퍼를 만들어 팀원과 친구들의 메시지를 모아보세요. 따뜻한 순간을 한 곳에서 기록할 수 있어요.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 420)
            }

            Button(action: onTapCreate) {
                Text("새 롤링페이퍼 만들기")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: 280)
        }
        .padding(.horizontal, HomeViewMetrics.emptyStatePadding)
        .padding(.vertical, HomeViewMetrics.emptyStatePadding * 1.5)
    }

    private var icon: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.12))
                .frame(width: 140, height: 140)
            Image(systemName: "sparkles")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(Color.accentColor)
        }
        .accessibilityHidden(true)
    }
}

#Preview("Home – With Papers") {
    NavigationStack {
        HomeView(viewModel: .preview, onOpenPaper: { _ in })
            .environmentObject(AppNavigator())
    }
}

#Preview("Home – Empty") {
    NavigationStack {
        HomeView(viewModel: HomeViewModel(summaries: []), onOpenPaper: { _ in })
            .environmentObject(AppNavigator())
    }
}
