import SwiftUI

struct VoiceObjectView: View {
    let object: VoiceObject
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: .rpSpaceS) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(formatTime(object.duration))
                .font(Typography.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.rpSpaceL)
        .background(
            RoundedRectangle(cornerRadius: .rpCornerM + 6, style: .continuous)
                .fill(.regularMaterial)
        )
        .shadow(color: ShadowTokens.medium.color,
                radius: isSelected ? ShadowTokens.medium.radius * 2 : ShadowTokens.medium.radius,
                y: isSelected ? ShadowTokens.medium.y * 2.5 : ShadowTokens.medium.y)
        .overlay(
            RoundedRectangle(cornerRadius: .rpCornerM + 6)
                .stroke(
                    isSelected ? Color.accentColor : Color.clear,
                    lineWidth: isSelected ? 3 : 0
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
