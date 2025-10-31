import SwiftUI

struct PaperFormBasicsSection: View {
    @Binding var draft: PaperFormDraft
    var showsDeadline: Bool = true
    var showsVisibilityToggle: Bool = true

    private let titleLimit = 60

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            titleField
            descriptionField

            if showsDeadline {
                deadlineField
            }

            if showsVisibilityToggle {
                visibilityToggle
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.regularMaterial)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
    }

    private var titleField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("제목")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("예: 생일 축하 메시지", text: $draft.title)
                .textFieldStyle(.roundedBorder)
                .onChange(of: draft.title) { _, newValue in
                    guard newValue.count > titleLimit else { return }
                    draft.title = String(newValue.prefix(titleLimit))
                }
                .accessibilityHint("Paper 제목은 최대 60자까지 입력할 수 있습니다.")

            if !draft.isTitleValid {
                Text(draft.titleErrorMessage ?? "")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("설명")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextEditor(text: $draft.description)
                .frame(minHeight: 140)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                )
        }
    }

    private var deadlineField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("마감일")
                .font(.caption)
                .foregroundStyle(.secondary)

            DatePicker("마감일", selection: $draft.dueDate, in: Date()..., displayedComponents: [.date])
                .datePickerStyle(.compact)
                .labelsHidden()
                .accessibilityLabel("마감일 선택")

            Text("마감일 이후에는 새로운 메시지를 받을 수 없어요.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var visibilityToggle: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("공개 여부")
                .font(.caption)
                .foregroundStyle(.secondary)

            Toggle(isOn: $draft.isPublic) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(draft.isPublic ? "공개 Paper" : "비공개 Paper")
                        .font(.headline)
                    Text(draft.isPublic ? "링크를 공유하면 누구나 메시지를 남길 수 있어요." : "초대받은 사용자만 접근 가능합니다.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityLabel("공개 여부 전환")
        }
    }
}

#if DEBUG
struct PaperFormBasicsSection_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PaperFormBasicsSection(draft: .constant(.preview))
                .padding()
                .background(Color(.systemGroupedBackground))
                .previewDisplayName("Light")

            PaperFormBasicsSection(draft: .constant(.preview),
                                   showsDeadline: false,
                                   showsVisibilityToggle: false)
                .padding()
                .background(Color(.systemGroupedBackground))
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark")
        }
    }
}
#endif

