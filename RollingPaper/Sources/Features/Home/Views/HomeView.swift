import SwiftUI

private enum HomeViewMetrics {
    static let sectionSpacing = AppConstants.Spacing.xxxl
    static let gridSpacing = AppConstants.Grid.spacing
    static let contentPadding = AppConstants.Spacing.xxl
    static let emptyStateSpacing = AppConstants.Spacing.xxxl
    static let emptyStatePadding = AppConstants.Spacing.xxxl
    static let toolbarIconFont = Typography.title3
}

struct HomeView: View {
    @Environment(\.interactionFeedbackCenter) private var feedbackCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var viewModel: HomeViewModel
    @State private var createViewModel = HomeCreateViewModel()
    @State private var activeSheet: HomeSheet?

    private let onOpenPaper: ((UUID) -> Void)?

    init(viewModel: HomeViewModel? = nil,
         onOpenPaper: ((UUID) -> Void)? = nil) {
        _viewModel = State(wrappedValue: viewModel ?? HomeViewModel())
        self.onOpenPaper = onOpenPaper
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: AppConstants.MaxWidth.gridItemMin, maximum: AppConstants.MaxWidth.gridItemMax), spacing: HomeViewMetrics.gridSpacing, alignment: .top)]
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
                    activeSheet = .joinPaper
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
        .sheet(item: $activeSheet) { sheet in
            sheetContent(for: sheet)
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
        activeSheet = .createPaper
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
    private func sheetContent(for sheet: HomeSheet) -> some View {
        switch sheet {
        case .createPaper:
            HomeCreateSheet(
                viewModel: createViewModel,
                onCancel: { activeSheet = nil },
                onComplete: { activeSheet = nil }
            )
            .onAppear { createViewModel.prepareForNewPaper() }
        case .joinPaper:
            JoinCodeSheet(
                recentCodes: viewModel.recentJoinCodes,
                onJoin: { code in try await viewModel.joinPaper(with: code) },
                onSuccess: { summary in
                    activeSheet = nil
                    onOpenPaper?(summary.id)
                },
                onDismiss: { activeSheet = nil }
            )
            .presentationDetents([.medium, .large])
        }
    }
}

private enum HomeSheet: Identifiable {
    case createPaper
    case joinPaper

    var id: String {
        switch self {
        case .createPaper:
            return "create-paper"
        case .joinPaper:
            return "join-paper"
        }
    }
}

private struct HomeEmptyStateView: View {
    let onTapCreate: () -> Void

    var body: some View {
        VStack(spacing: HomeViewMetrics.emptyStateSpacing) {
            icon

            VStack(spacing: .rpSpaceM) {
                Text("아직 생성된 롤링페이퍼가 없어요")
                    .font(Typography.title3)
                    .multilineTextAlignment(.center)
                Text("새 롤링페이퍼를 만들어 팀원과 친구들의 메시지를 모아보세요. 따뜻한 순간을 한 곳에서 기록할 수 있어요.")
                    .font(Typography.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: AppConstants.MaxWidth.text)
            }

            Button(action: onTapCreate) {
                Text("새 롤링페이퍼 만들기")
                    .font(Typography.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: AppConstants.MaxWidth.button)
        }
        .padding(.horizontal, HomeViewMetrics.emptyStatePadding)
        .padding(.vertical, HomeViewMetrics.emptyStatePadding * 1.5)
    }

    private var icon: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(OpacityTokens.subtle))
                .frame(width: AppConstants.IconSize.emptyStateBackground, height: AppConstants.IconSize.emptyStateBackground)
            Image(systemName: "sparkles")
                .font(.system(size: AppConstants.IconSize.emptyState, weight: .semibold))
                .foregroundStyle(Color.accentColor)
        }
        .accessibilityHidden(true)
    }
}

#Preview("Home – With Papers") {
    NavigationStack {
        HomeView(viewModel: .preview, onOpenPaper: { _ in })
    }
}

#Preview("Home – Empty") {
    NavigationStack {
        HomeView(viewModel: HomeViewModel(summaries: []), onOpenPaper: { _ in })
    }
}
