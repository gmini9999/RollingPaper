import SwiftUI

public enum RPButtonVariant: CaseIterable {
    case primary
    case secondary
    case tertiary
    case destructive
    case link
}

public enum RPButtonSize {
    case large
    case medium
    case small

    var font: Font {
        switch self {
        case .large:
            return .rpHeadingM
        case .medium:
            return .rpBodyM
        case .small:
            return .rpBodyM
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .large:
            return .rpSpaceS
        case .medium:
            return 10
        case .small:
            return 8
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .large:
            return .rpSpaceL
        case .medium:
            return .rpSpaceM
        case .small:
            return .rpSpaceS
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .large:
            return 14
        case .medium:
            return 12
        case .small:
            return 10
        }
    }

    var iconSpacing: CGFloat {
        switch self {
        case .large:
            return .rpSpaceS
        case .medium, .small:
            return .rpSpaceXS
        }
    }
}

public struct RPButton: View {
    private let title: String
    private let variant: RPButtonVariant
    private let size: RPButtonSize
    private let leadingIcon: Image?
    private let trailingIcon: Image?
    private let isEnabled: Bool
    private let fillsWidth: Bool
    private let action: () -> Void

    @Environment(\.interface) private var interfaceProvider

    public init(_ title: String,
                variant: RPButtonVariant = .primary,
                size: RPButtonSize = .large,
                leadingIcon: Image? = nil,
                trailingIcon: Image? = nil,
                isEnabled: Bool = true,
                fillsWidth: Bool = true,
                action: @escaping () -> Void) {
        self.title = title
        self.variant = variant
        self.size = size
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.isEnabled = isEnabled
        self.fillsWidth = fillsWidth
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: size.iconSpacing) {
                if let leadingIcon {
                    leadingIcon
                        .font(.system(size: size == .small ? 14 : 16, weight: .semibold))
                }

                if variant == .link {
                    Text(title)
                        .font(size.font)
                        .lineLimit(1)
                        .underline(true, color: .rpPrimary)
                } else {
                    Text(title)
                        .font(size.font)
                        .lineLimit(1)
                }

                if let trailingIcon {
                    trailingIcon
                        .font(.system(size: size == .small ? 14 : 16, weight: .semibold))
                }
            }
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .frame(maxWidth: fillsWidth ? .infinity : nil)
            .contentShape(Rectangle())
        }
        .buttonStyle(
            RPButtonStyle(
                variant: variant,
                size: size,
                isEnabled: isEnabled,
                reducesMotion: interfaceProvider.reduceMotion
            )
        )
        .disabled(!isEnabled)
        .accessibilityLabel(title)
        .accessibilityHint(accessibilityHint)
    }

    private var accessibilityHint: String {
        switch variant {
        case .primary:
            return "기본 주요 버튼"
        case .secondary:
            return "보조 버튼"
        case .tertiary:
            return "텍스트 버튼"
        case .destructive:
            return "위험 동작"
        case .link:
            return "링크 스타일 버튼"
        }
    }
}

private struct RPButtonStyle: ButtonStyle {
    let variant: RPButtonVariant
    let size: RPButtonSize
    let isEnabled: Bool
    let reducesMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minHeight: minimumHeight)
            .foregroundColor(variant.foregroundColor(isEnabled: isEnabled))
            .background(variant.backgroundColor(isPressed: configuration.isPressed, isEnabled: isEnabled))
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .strokeBorder(variant.borderColor(isEnabled: isEnabled), lineWidth: variant.borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
            .opacity(isEnabled ? 1 : 0.6)
            .animation(.rp(.fast, reduceMotion: reducesMotion), value: configuration.isPressed)
    }

    private var minimumHeight: CGFloat {
        switch size {
        case .large:
            return 52
        case .medium:
            return 44
        case .small:
            return 36
        }
    }
}

private extension RPButtonVariant {
    func foregroundColor(isEnabled: Bool) -> Color {
        switch self {
        case .primary, .destructive:
            return .rpTextInverse
        case .secondary, .tertiary, .link:
            return isEnabled ? .rpPrimary : Color.rpPrimary.opacity(0.6)
        }
    }

    func backgroundColor(isPressed: Bool, isEnabled: Bool) -> Color {
        let baseOpacity: Double = isEnabled ? 1 : 0.5

        switch self {
        case .primary:
            return (isPressed ? Color.rpPrimaryAlt : .rpPrimary).opacity(baseOpacity)
        case .secondary:
            return (isPressed ? Color.rpSurface : .rpSurfaceAlt).opacity(baseOpacity)
        case .tertiary, .link:
            return Color.clear
        case .destructive:
            return (isPressed ? Color.rpDanger.opacity(0.9) : .rpDanger).opacity(baseOpacity)
        }
    }

    func borderColor(isEnabled: Bool) -> Color {
        switch self {
        case .secondary:
            return isEnabled ? .rpPrimary : Color.rpPrimary.opacity(0.4)
        case .tertiary:
            return Color.rpSurfaceAlt.opacity(isEnabled ? 0.7 : 0.4)
        case .link:
            return .clear
        case .primary, .destructive:
            return .clear
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .secondary:
            return 1
        case .tertiary:
            return 1
        case .primary, .destructive, .link:
            return 0
        }
    }
}
