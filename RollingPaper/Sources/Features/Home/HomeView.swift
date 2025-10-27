import SwiftUI

struct HomeView: View {
    @Environment(\.interactionFeedbackCenter) private var feedbackCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var coordinator: NavigationCoordinator

    @StateObject private var viewModel: HomeViewModel
    @StateObject private var createViewModel = HomeCreateViewModel()

    private let onOpenPaper: ((UUID) -> Void)?

    init(viewModel: HomeViewModel? = nil,
         onOpenPaper: ((UUID) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? HomeViewModel())
        self.onOpenPaper = onOpenPaper
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 320, maximum: 420), spacing: .rpSpaceL, alignment: .top)]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: .rpSpaceXL) {
                if viewModel.hasPapers {
                    cardGallery
                } else {
                    HomeEmptyStateView(onTapCreate: handleCreateTapped)
                    .padding(.horizontal, .rpSpaceL)
                }
            }
            .padding(.vertical, .rpSpaceXL)
            .background(Color.rpSurfaceAlt.ignoresSafeArea())
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: .rpSpaceS) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.rpPrimary.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.rpPrimary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("RollingPaper")
                            .font(.rpHeadingM)
                            .foregroundStyle(Color.rpTextPrimary)
                        Text("함께 만드는 메시지")
                            .font(.rpCaption)
                            .foregroundStyle(Color.rpTextSecondary)
                    }
                }
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    feedbackCenter.trigger(
                        haptic: .selection,
                        animation: .subtle,
                        reduceMotion: reduceMotion
                    )
                    coordinator.present(.joinPaper)
                } label: {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(Color.rpPrimary)
                }
                .accessibilityLabel("참여하기")

                Button(action: handleCreateTapped) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(Color.rpPrimary)
                }
                .accessibilityLabel("새로 만들기")
            }
        }
        .sheet(item: $coordinator.activeModal, onDismiss: coordinator.dismissModal) { modal in
            modalContent(for: modal)
        }
    }

    private var cardGallery: some View {
        LazyVGrid(columns: columns, spacing: .rpSpaceXL) {
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
        .padding(.horizontal, .rpSpaceL)
    }

    private func handleCreateTapped() {
        feedbackCenter.trigger(
            haptic: .impact(style: .medium),
            animation: .tap,
            reduceMotion: reduceMotion
        )
        createViewModel.prepareForNewPaper()
        coordinator.present(.createPaper)
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
                onCancel: coordinator.dismissModal,
                onComplete: coordinator.dismissModal
            )
            .presentationDetents([.medium, .large])
            .onAppear { createViewModel.prepareForNewPaper() }
        case .joinPaper:
            JoinCodeSheet(
                recentCodes: viewModel.recentJoinCodes,
                onJoin: { code in try await viewModel.joinPaper(with: code) },
                onSuccess: { summary in
                    coordinator.dismissModal()
                    onOpenPaper?(summary.id)
                },
                onDismiss: coordinator.dismissModal
            )
            .presentationDetents([.medium, .large])
        }
    }
}

private struct HomeEmptyStateView: View {
    let onTapCreate: () -> Void

    var body: some View {
        VStack(spacing: .rpSpaceXL) {
            icon

            VStack(spacing: .rpSpaceS) {
                Text("아직 생성된 롤링페이퍼가 없어요")
                    .font(.rpHeadingM)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.rpTextPrimary)

                Text("새 롤링페이퍼를 만들어 팀원과 친구들의 메시지를 모아보세요. 따뜻한 순간을 한 곳에서 기록할 수 있어요.")
                    .font(.rpBodyM)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.rpTextPrimary.opacity(0.75))
                    .frame(maxWidth: 420)
            }

            RPButton("새 롤링페이퍼 만들기") {
                onTapCreate()
            }
            .frame(maxWidth: 280)
        }
        .padding(.horizontal, .rpSpaceXL)
        .padding(.vertical, .rpSpaceXXL)
    }

    private var icon: some View {
        ZStack {
            Circle()
                .fill(Color.rpPrimary.opacity(0.12))
                .frame(width: 140, height: 140)
            Image(systemName: "sparkles")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(Color.rpPrimary)
        }
        .accessibilityHidden(true)
    }
}

#Preview("Home – With Papers") {
    NavigationStack {
        let provider = InterfaceProvider()
        HomeView(viewModel: .preview, onOpenPaper: { _ in })
            .environmentObject(provider)
            .environmentObject(NavigationCoordinator())
            .interface(provider)
    }
}

#Preview("Home – Empty") {
    NavigationStack {
        let provider = InterfaceProvider()
        HomeView(viewModel: HomeViewModel(summaries: []), onOpenPaper: { _ in })
            .environmentObject(provider)
            .environmentObject(NavigationCoordinator())
            .interface(provider)
    }
}
