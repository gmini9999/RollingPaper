import SwiftUI
import PaperKit

struct PaperView: View {
    let paperID: UUID?
    var onShare: ((UUID) -> Void)?

    @Environment(\.adaptiveLayoutContext) private var layout

    @StateObject private var paperKitState = PaperKitState()
    @StateObject private var canvasStore = PaperCanvasStore()
    @StateObject private var gestureManager = GestureCoordinationManager()

    var body: some View {
        ZStack(alignment: .bottom) {
            PaperKitContainerView(state: paperKitState)
                .ignoresSafeArea()

            CustomObjectsOverlay(objects: canvasStore.objects)
                .environmentObject(canvasStore)
                .environmentObject(gestureManager)
                .ignoresSafeArea()
        }
        .navigationTitle(editorTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let id = paperID {
                    Button(action: { onShare?(id) }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3.weight(.semibold))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.tint)
                    .accessibilityLabel("공유")
                }
            }
        }
        .toolbarBackground(.regularMaterial, for: .navigationBar)
        .environmentObject(gestureManager)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomToolbarView(
                paperKitState: paperKitState,
                canvasStore: canvasStore
            )
            .padding(.horizontal, bottomToolbarHorizontalPadding)
            .padding(.top, 12)
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
            return 32
        case .medium:
            return 24
        case .compact:
            return 20
        }
    }
}

#Preview("Paper Editor – Create") {
    return PaperView(paperID: nil)
        .environment(\.adaptiveLayoutContext, .fallback)
        .environmentObject(AppNavigator())
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
    return PaperView(paperID: UUID())
        .environment(\.adaptiveLayoutContext, expanded)
        .environmentObject(AppNavigator())
        .interactionFeedbackCenter(InteractionFeedbackCenter.shared)
}
