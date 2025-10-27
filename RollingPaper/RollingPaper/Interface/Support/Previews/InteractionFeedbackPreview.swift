import SwiftUI

private struct InteractionFeedbackPreview: View {
    @StateObject private var feedbackCenter = RPInteractionFeedbackCenter.shared
    @StateObject private var interfaceProvider = InterfaceProvider()

    var body: some View {
        VStack(spacing: .rpSpaceL) {
            RPButton("성공 피드백") {
                feedbackCenter.trigger(
                    haptic: .impact(style: .medium),
                    sound: .success,
                    animation: .tap,
                    reduceMotion: interfaceProvider.reduceMotion
                )
            }

            RPButton("경고 피드백", variant: .secondary) {
                feedbackCenter.trigger(
                    haptic: .notification(type: .warning),
                    sound: .warning,
                    animation: .emphasize,
                    reduceMotion: interfaceProvider.reduceMotion
                )
            }
        }
        .padding(.rpSpaceL)
        .interface(interfaceProvider)
        .interactionFeedbackCenter(feedbackCenter)
    }
}

struct InteractionFeedbackPreview_Previews: PreviewProvider {
    static var previews: some View {
        InteractionFeedbackPreview()
            .previewDisplayName("Interaction Feedback")
    }
}
