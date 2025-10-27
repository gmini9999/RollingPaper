import SwiftUI

struct HomeView: View {
    var onCreatePaper: (() -> Void)?
    var onOpenPaper: ((UUID) -> Void)?
    @Environment(\.adaptiveLayoutContext) private var layout

    private let samplePapers: [UUID] = [UUID(), UUID(), UUID()]

    var body: some View {
        Group {
            switch layout.breakpoint {
            case .compact, .medium:
                listLayout
            case .expanded:
                expandedLayout
            }
        }
        .navigationTitle("Home")
    }

    @ViewBuilder
    private var listLayout: some View {
        let listContent = List {
            Section("Create") {
                RPButton("New Paper") {
                    onCreatePaper?()
                }
            }

            Section("Recent") {
                ForEach(samplePapers, id: \.self) { id in
                    Button {
                        onOpenPaper?(id)
                    } label: {
                        VStack(alignment: .leading, spacing: .rpSpaceS) {
                            Text("Paper #\(id.uuidString.prefix(6))")
                                .font(.rpHeadingM)
                            Text("Tap to open")
                                .font(.rpBodyM)
                                .foregroundColor(.rpTextPrimary)
                        }
                        .padding(.vertical, .rpSpaceXS)
                    }
                }
            }
        }

        if layout.isPad {
            listContent
                .listStyle(.sidebar)
        } else {
            listContent
                .listStyle(.insetGrouped)
        }
    }

    private var expandedLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .rpSpaceL) {
                VStack(alignment: .leading, spacing: .rpSpaceM) {
                    Text("Create")
                        .font(.rpHeadingM)
                    RPButton("New Paper") {
                        onCreatePaper?()
                    }
                    Text("Start a fresh message or gather signatures with a single tap.")
                        .font(.rpBodyM)
                        .foregroundColor(.rpTextPrimary)
                }

                Text("Recent Papers")
                    .font(.rpHeadingM)

                LazyVGrid(columns: expandedColumns, spacing: .rpSpaceM) {
                    ForEach(samplePapers, id: \.self) { id in
                        Button {
                            onOpenPaper?(id)
                        } label: {
                            recentCard(for: id)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .adaptiveContentContainer()
            .padding(.bottom, .rpSpaceL)
        }
        .background(Color.clear)
    }

    private var expandedColumns: [GridItem] {
        [GridItem(.flexible(), spacing: .rpSpaceM), GridItem(.flexible(), spacing: .rpSpaceM)]
    }

    private func recentCard(for id: UUID) -> some View {
        VStack(alignment: .leading, spacing: .rpSpaceS) {
            Text("Paper #\(id.uuidString.prefix(6))")
                .font(.rpHeadingM)
            Text("Tap to open")
                .font(.rpBodyM)
                .foregroundColor(.rpTextPrimary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.rpSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.rpSurfaceAlt, lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview("Home – Compact") {
    let provider = InterfaceProvider()
    return HomeView(onCreatePaper: {}, onOpenPaper: { _ in })
        .environment(\.adaptiveLayoutContext, .fallback)
        .environmentObject(provider)
        .interface(provider)
}

#Preview("Home – Expanded") {
    let provider = InterfaceProvider()
    let expanded = AdaptiveLayoutContext(
        breakpoint: .expanded,
        idiom: .pad,
        isLandscape: true,
        width: 1280,
        height: 960
    )
    return HomeView(onCreatePaper: {}, onOpenPaper: { _ in })
        .environment(\.adaptiveLayoutContext, expanded)
        .environmentObject(provider)
        .interface(provider)
}
