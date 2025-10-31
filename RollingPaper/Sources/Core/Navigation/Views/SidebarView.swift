import SwiftUI

/// Sidebar container used in iPad navigation split view.
struct AppNavigationSidebarView: View {
    @Binding var selection: SidebarDestination?
    var onSelect: (SidebarDestination) -> Void

    private var listSelection: Binding<SidebarDestination?> {
        Binding(
            get: { selection },
            set: { newValue in
                guard let destination = newValue else { return }
                onSelect(destination)
            }
        )
    }

    var body: some View {
        List(selection: listSelection) {
            Section(L10n.Navigation.Sidebar.sectionMain) {
                ForEach(SidebarDestination.primaryDestinations) { destination in
                    row(for: destination)
                        .tag(destination)
                }
            }

            Section(L10n.Navigation.Sidebar.sectionPaper) {
                ForEach(SidebarDestination.actionDestinations) { destination in
                    row(for: destination)
                        .tag(destination)
                }
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .contentMargins(.vertical, 8)
        .navigationTitle(L10n.Navigation.Sidebar.title)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.regularMaterial)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, y: 6)
        .padding(.vertical, 16)
        .padding(.trailing, 16)
    }

    private func row(for destination: SidebarDestination) -> some View {
        let isActive = selection == destination && !destination.isActionOnly

        return HStack {
            Label {
                Text(destination.title)
                    .font(isActive ? .headline : .body)
                    .foregroundStyle(isActive ? Color.accentColor : Color.primary)
            } icon: {
                Image(systemName: destination.systemImage)
                    .font(.title3.weight(.semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
        .listRowBackground(isActive ? Color.accentColor.opacity(0.12) : Color.clear)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

