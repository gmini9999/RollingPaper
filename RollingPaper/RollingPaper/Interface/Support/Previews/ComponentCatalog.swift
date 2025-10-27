import SwiftUI

private struct ComponentCatalogPreview: View {
    @State private var primaryText: String = ""
    @State private var noteText: String = ""
    @StateObject private var toastCenter = RPToastCenter()
    @StateObject private var interfaceProvider = InterfaceProvider()

    var body: some View {
        RPToastContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: .rpSpaceL) {
                    buttonSection
                    inputSection
                    surfaceSection
                    feedbackSection
                }
                .padding(.rpSpaceL)
                .animation(.rp(.standard, reduceMotion: interfaceProvider.reduceMotion), value: primaryText)
            }
        }
        .toastCenter(toastCenter)
        .interface(interfaceProvider)
        .onAppear {
            toastCenter.show(RPToast(title: "새 롤링페이퍼",
                                     message: "친구들을 초대하여 메시지를 받아보세요.",
                                     style: .success))
        }
    }

    private var buttonSection: some View {
        VStack(alignment: .leading, spacing: .rpSpaceS) {
            Text("Buttons")
                .font(.rpHeadingM)

            RPButton("Primary CTA") { }
            RPButton("Secondary", variant: .secondary) { }
            RPButton("Tertiary", variant: .tertiary, fillsWidth: false) { }
            RPButton("Destructive", variant: .destructive) { }
            RPButton("자세히 보기", variant: .link, fillsWidth: false) { }
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: .rpSpaceS) {
            Text("Inputs")
                .font(.rpHeadingM)

            RPTextField("이름을 입력하세요", text: $primaryText, title: "제목")
            RPTextField("이메일", text: $primaryText, title: "이메일", helperText: "알림을 받을 이메일 주소", state: .success)
            RPTextArea("메시지를 작성하세요", text: $noteText, title: "내용", helperText: "최소 10자 이상")
        }
    }

    private var surfaceSection: some View {
        VStack(alignment: .leading, spacing: .rpSpaceS) {
            Text("Surfaces")
                .font(.rpHeadingM)

            RPCard {
                Text("친구 전용 이벤트")
                    .font(.rpHeadingM)
                Text("초대 링크를 공유하고 메시지를 받아보세요.")
                    .font(.rpBodyM)
            }

            RPListRow {
                VStack(alignment: .leading, spacing: .rpSpaceXS) {
                    Text("혜진의 롤링페이퍼")
                    Text("2일 남음")
                        .font(.rpBodyM)
                        .foregroundColor(.rpPrimary)
                }
            } trailing: {
                RPBadge("NEW", style: .info)
            }
        }
    }

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: .rpSpaceS) {
            Text("Feedback")
                .font(.rpHeadingM)

            RPLoadingIndicator(style: .spinner, message: "로딩 중")
            RPBadge("완료", style: .success)
            RPBadge("경고", style: .warning)
            RPBadge("실패", style: .critical)
        }
    }
}

struct ComponentCatalog_Previews: PreviewProvider {
    static var previews: some View {
        ComponentCatalogPreview()
            .previewDisplayName("Component Catalog")

        ComponentCatalogPreview()
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Component Catalog - Dark")
    }
}
