import SwiftUI

struct PaperFormBasicsSection: View {
    @Binding var draft: PaperFormDraft
    var titleValidationState: RPFieldState = .normal
    var titleValidationMessage: String?
    var showsDeadline: Bool = true
    var showsVisibilityToggle: Bool = true

    private let titleLimit = 60

    var body: some View {
        VStack(alignment: .leading, spacing: .rpSpaceL) {
            VStack(alignment: .leading, spacing: .rpSpaceM) {
                titleField
                descriptionField
            }

            if showsDeadline {
                Divider().padding(.vertical, .rpSpaceS)
                deadlineField
            }

            if showsVisibilityToggle {
                Divider().padding(.vertical, .rpSpaceS)
                visibilityToggle
            }
        }
    }

    private var titleField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("제목")
                .font(.rpCaption)
                .foregroundColor(.rpTextSecondary)

            RPTextField("예: 생일 축하 메시지",
                        text: $draft.title,
                        title: nil,
                        helperText: titleValidationMessage,
                        state: titleValidationState)
                .onChange(of: draft.title) { _, newValue in
                    guard newValue.count > titleLimit else { return }
                    draft.title = String(newValue.prefix(titleLimit))
                }
                .accessibilityHint("Paper 제목은 최대 60자까지 입력할 수 있습니다.")
        }
    }

    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("설명")
                .font(.rpCaption)
                .foregroundColor(.rpTextSecondary)

            RPTextArea("축하 메시지나 진행 노트를 입력하세요",
                       text: $draft.description,
                       title: nil,
                       helperText: nil,
                       minimumHeight: 140)
        }
    }

    private var deadlineField: some View {
        RPFormField(title: "마감일", helperText: "마감일 이후에는 새로운 메시지를 받을 수 없어요.") {
            PaperFormInputContainer {
                DatePicker("마감일", selection: $draft.dueDate, in: Date()..., displayedComponents: [.date])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .accessibilityLabel("마감일 선택")
            }
        }
    }

    private var visibilityToggle: some View {
        RPFormField(title: "공개 여부", helperText: draft.isPublic ? "누구나 링크로 Paper에 참여할 수 있습니다." : "초대한 사람만 Paper를 볼 수 있습니다.") {
            PaperFormInputContainer {
                Toggle(isOn: $draft.isPublic) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(draft.isPublic ? "공개 Paper" : "비공개 Paper")
                            .font(.rpBodyM)
                            .foregroundColor(.rpTextPrimary)
                        Text(draft.isPublic ? "링크를 공유하면 누구나 메시지를 남길 수 있어요." : "초대받은 사용자만 접근 가능합니다.")
                            .font(.rpCaption)
                            .foregroundColor(.rpTextSecondary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .rpPrimary))
                .accessibilityLabel("공개 여부 전환")
            }
        }
    }
}

private struct PaperFormInputContainer<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        let base = RoundedRectangle(cornerRadius: 12, style: .continuous)
        content
            .padding(.horizontal, .rpSpaceM)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RPFieldState.normal.backgroundColor)
            .overlay(base.stroke(RPFieldState.normal.borderColor(isFocused: false), lineWidth: 1))
            .clipShape(base)
            .contentShape(Rectangle())
    }
}

#if DEBUG
struct PaperFormBasicsSection_Previews: PreviewProvider {
    static var previews: some View {
        let provider = InterfaceProvider()
        Group {
            PaperFormBasicsSection(draft: .constant(.preview))
                .environmentObject(provider)
                .interface(provider)
                .padding()
                .background(Color.rpSurfaceAlt)
                .previewDisplayName("Light")

            PaperFormBasicsSection(draft: .constant(.preview),
                                   titleValidationState: .error,
                                   titleValidationMessage: "제목을 입력해 주세요.",
                                   showsDeadline: false,
                                   showsVisibilityToggle: false)
                .environmentObject(provider)
                .interface(provider)
                .padding()
                .background(Color.black)
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark")
        }
    }
}
#endif

