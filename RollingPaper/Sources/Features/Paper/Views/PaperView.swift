import SwiftUI
import PaperKit

struct PaperView: View {
    let paperID: UUID?
    var onShare: ((UUID) -> Void)?

    @Environment(\.adaptiveLayoutContext) private var layout

    @State private var paperKitState = PaperKitState()
    @State private var canvasStore = PaperCanvasStore()
    @State private var gestureManager = GestureCoordinationManager()

    var body: some View {
        ZStack(alignment: .bottom) {
            PaperKitContainerView(state: paperKitState)
                .ignoresSafeArea()

            CustomObjectsOverlay(objects: canvasStore.objects)
                .environment(canvasStore)
                .environment(gestureManager)
                .ignoresSafeArea()
        }
        .navigationTitle(editorTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let id = paperID {
                    Button(action: { onShare?(id) }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(Typography.title3)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.tint)
                    .accessibilityLabel("공유")
                }
            }
        }
        .toolbarBackground(.regularMaterial, for: .navigationBar)
        .environment(gestureManager)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomToolbarView(
                paperKitState: paperKitState,
                canvasStore: canvasStore
            )
            .padding(.horizontal, bottomToolbarHorizontalPadding)
            .padding(.top, .rpSpaceM)
        }
        .onAppear {
            gestureManager.prepareHapticEngine()
        }
    }

    private var editorTitle: String {
        guard let id = paperID else {
            return "Paper"
        }
        return "Paper #\(id.uuidString.prefix(6))"
    }
}

private extension PaperView {
    var bottomToolbarHorizontalPadding: CGFloat {
        switch layout.breakpoint {
        case .expanded:
            return .rpSpaceXXXL
        case .medium:
            return .rpSpaceXXL
        case .compact:
            return .rpSpaceXL
        }
    }
}

#Preview("Paper Editor – Create") {
    PaperView(paperID: nil)
        .environment(\.adaptiveLayoutContext, .fallback)
        .environment(AppNavigator())
        .interactionFeedbackCenter(InteractionFeedbackCenter.shared)
}

#Preview("Paper Editor – Expanded Detail") {
    let expanded = AdaptiveLayoutContext(
        breakpoint: .expanded,
        idiom: .pad,
        isLandscape: true,
        width: 1180,
        height: 820
    )
    PaperView(paperID: UUID())
        .environment(\.adaptiveLayoutContext, expanded)
        .environment(AppNavigator())
        .interactionFeedbackCenter(InteractionFeedbackCenter.shared)
}
