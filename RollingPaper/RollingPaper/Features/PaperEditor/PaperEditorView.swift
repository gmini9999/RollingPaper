import SwiftUI

struct PaperEditorView: View {
    let paperID: UUID?
    var onShare: ((UUID) -> Void)?
    @Environment(\.adaptiveLayoutContext) private var layout

    var body: some View {
        Group {
            switch layout.breakpoint {
            case .compact, .medium:
                compactContent
            case .expanded:
                expandedContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.rpSurfaceAlt)
    }

    private var editorTitle: String {
        if let id = paperID {
            return "Editing Paper #\(id.uuidString.prefix(6))"
        }
        return "Create New Paper"
    }

    private var editorContent: some View {
        VStack(spacing: .rpSpaceM) {
            Text(editorTitle)
                .font(layout.breakpoint == .expanded ? .rpHeadingL : .rpHeadingM)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Editor placeholder")
                .font(.rpBodyM)
                .foregroundColor(.rpTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let id = paperID {
                RPButton("Share") {
                    onShare?(id)
                }
            }
        }
    }

    private var compactContent: some View {
        editorContent
            .adaptiveContentContainer()
    }

    private var expandedContent: some View {
        HStack(alignment: .top, spacing: .rpSpaceM) {
            editorContent
                .frame(maxWidth: 520)

            VStack(alignment: .leading, spacing: .rpSpaceM) {
                Text("Preview & Tips")
                    .font(.rpHeadingM)
                Text("Use the supplementary column to keep a preview or note references while editing. This area automatically adapts when sharing a paper.")
                    .font(.rpBodyM)
                    .foregroundColor(.rpTextPrimary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.rpSurface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .adaptiveContentContainer()
    }
}

#Preview("Paper Editor – Create") {
    let provider = InterfaceProvider()
    return PaperEditorView(paperID: nil)
        .environment(\.adaptiveLayoutContext, .fallback)
        .environmentObject(provider)
        .interface(provider)
}

#Preview("Paper Editor – Expanded Detail") {
    let provider = InterfaceProvider()
    let expanded = AdaptiveLayoutContext(
        breakpoint: .expanded,
        idiom: .pad,
        isLandscape: true,
        width: 1180,
        height: 820
    )
    return PaperEditorView(paperID: UUID())
        .environment(\.adaptiveLayoutContext, expanded)
        .environmentObject(provider)
        .interface(provider)
}
