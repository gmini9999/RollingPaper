import SwiftUI

struct SocialLoginButton: View {
    enum ProviderStyle {
        case apple
        case google

        var title: String {
            switch self {
            case .apple:
                return "Continue with Apple"
            case .google:
                return "Continue with Google"
            }
        }
    }

    let style: ProviderStyle
    var title: String?
    var isLoading: Bool = false
    var isEnabled: Bool = true
    var action: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicType
    var body: some View {
        Button(action: action) {
            HStack(spacing: .rpSpaceS) {
                icon
                    .font(.system(size: iconSize, weight: .regular))
                    .frame(width: iconSize, height: iconSize)

                Text(buttonTitle)
                    .font(.system(size: fontSize, weight: .semibold, design: .default))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .foregroundColor(textColor)

                Spacer()

                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(textColor)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .frame(height: buttonHeight)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(SocialLoginButtonStyle(style: style, isEnabled: isEnabled))
        .disabled(!isEnabled || isLoading)
        .accessibilityLabel(accessibilityLabel)
    }

    private var iconSize: CGFloat {
        switch dynamicType {
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
            return 28
        default:
            return 20
        }
    }

    private var fontSize: CGFloat {
        switch dynamicType {
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
            return 18
        default:
            return 16
        }
    }

    private var buttonHeight: CGFloat { 52 }

    private var horizontalPadding: CGFloat {
        switch dynamicType {
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
            return .rpSpaceL
        default:
            return .rpSpaceM
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .apple:
            return .white
        case .google:
            return Color(red: 0.24, green: 0.25, blue: 0.27)
        }
    }

    private var textColor: Color {
        switch style {
        case .apple:
            return Color.white.opacity(isLoading ? 0.85 : 1)
        case .google:
            return foregroundColor.opacity(isLoading ? 0.7 : 1)
        }
    }

    private var buttonTitle: String {
        title ?? style.title
    }

    private var accessibilityLabel: String {
        switch style {
        case .apple:
            return "Apple 계정으로 계속하기"
        case .google:
            return "Google 계정으로 계속하기"
        }
    }

    @ViewBuilder
    private var icon: some View {
        switch style {
        case .apple:
            Image(systemName: "apple.logo")
                .foregroundColor(foregroundColor)
        case .google:
            // Placeholder using SF Symbol; replace with branded asset if available.
            Image(systemName: "g.circle")
                .symbolRenderingMode(.multicolor)
        }
    }
}

private struct SocialLoginButtonStyle: ButtonStyle {
    let style: SocialLoginButton.ProviderStyle
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundColor(isPressed: configuration.isPressed))
            .overlay(borderOverlay)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .opacity(isEnabled ? 1 : 0.5)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        switch style {
        case .apple:
            return Color.black.opacity(isPressed ? 0.85 : 1)
        case .google:
            let base = Color.white
            let pressed = Color(red: 0.94, green: 0.95, blue: 0.96)
            return isPressed ? pressed : base
        }
    }

    private var borderOverlay: some View {
        Group {
            switch style {
            case .apple:
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.clear, lineWidth: 0)
            case .google:
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(googleBorderColor, lineWidth: 1)
            }
        }
    }

    private var googleBorderColor: Color {
        Color(red: 0.85, green: 0.86, blue: 0.88)
    }
}

#Preview("Social Login Buttons – Light") {
    VStack(spacing: 16) {
        SocialLoginButton(style: .apple, isLoading: false, action: {})
        SocialLoginButton(style: .google, isLoading: true, action: {})
    }
    .padding()
    .background(Color.rpSurface)
}

#Preview("Social Login Buttons – Dark") {
    VStack(spacing: 16) {
        SocialLoginButton(style: .apple, isLoading: false, action: {})
        SocialLoginButton(style: .google, isLoading: false, action: {})
    }
    .padding()
    .background(Color.rpSurface)
    .preferredColorScheme(.dark)
}

