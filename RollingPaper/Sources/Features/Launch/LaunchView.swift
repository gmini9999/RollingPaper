import SwiftUI

struct LaunchView: View {
    @Environment(\.adaptiveLayoutContext) private var layout
    @Environment(\.interface) private var interfaceProvider
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: layout.breakpoint == .expanded ? .rpSpaceXXL : .rpSpaceXL) {
                LaunchHeroView(reduceMotion: interfaceProvider.reduceMotion)
                    .frame(maxWidth: layout.breakpoint == .expanded ? 360 : 280)
                    .frame(height: layout.breakpoint == .expanded ? 280 : 220)
                    .accessibilityHidden(true)

                VStack(spacing: .rpSpaceS) {
                    Text("RollingPaper")
                        .font(layout.breakpoint == .expanded ? .rpHeadingL : .rpHeadingM)
                        .foregroundColor(titleColor)

                    Text("Loading your papers…")
                        .font(.rpBodyM)
                        .foregroundColor(statusColor)
                        .multilineTextAlignment(.center)
                        .accessibilityLabel("앱 환경을 불러오는 중")
                        .accessibilityHint("잠시 후 로그인 화면으로 이동합니다")

                    RPLoadingIndicator(style: .spinner)
                        .padding(.top, .rpSpaceXS)
                }
                .frame(maxWidth: .infinity)
            }
            .adaptiveContentContainer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color.rpSurface)
    }

    private var backgroundGradient: some View {
        let colors: [Color]

        if colorScheme == .dark {
            colors = [
                Color.rpSurface,
                Color.rpPrimary.opacity(0.35)
            ]
        } else {
            colors = [
                Color.rpPrimary.opacity(0.3),
                Color.rpSurface
            ]
        }

        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay(
                Color.black.opacity(colorScheme == .dark ? 0.2 : 0)
            )
            .drawingGroup()
    }

    private var titleColor: Color {
        colorScheme == .dark ? .rpTextInverse : .rpTextPrimary
    }

    private var statusColor: Color {
        colorScheme == .dark ? .rpTextInverse.opacity(0.85) : .rpTextPrimary.opacity(0.8)
    }
}

private struct LaunchHeroView: View {
    let reduceMotion: Bool

    @State private var isAppeared = false
    @State private var floatUp = false
    @State private var sparkleRotation: Double = 0
    @State private var shimmerPhase = false

    var body: some View {
        GeometryReader { proxy in
            let baseSize = min(proxy.size.width, proxy.size.height)

            ZStack {
                CardShape()
                    .fill(heroGradient)
                    .frame(width: baseSize * 0.78, height: baseSize * 0.62)
                    .shadow(color: Color.black.opacity(0.15), radius: 24, x: 0, y: 12)

                CardShape()
                    .fill(Color.rpSurface)
                    .frame(width: baseSize * 0.72, height: baseSize * 0.56)
                    .offset(x: -baseSize * 0.08, y: baseSize * 0.04)
                    .opacity(0.85)

                CardShape()
                    .stroke(Color.rpSurfaceAlt.opacity(0.9), lineWidth: 2)
                    .frame(width: baseSize * 0.68, height: baseSize * 0.52)
                    .offset(x: baseSize * 0.06, y: -baseSize * 0.05)

                VStack(spacing: .rpSpaceS) {
                    Image(systemName: "sparkles")
                        .font(.system(size: baseSize * 0.22, weight: .semibold))
                        .foregroundStyle(Color.rpAccent)
                        .rotationEffect(.degrees(sparkleRotation))
                        .opacity(reduceMotion ? 0.9 : shimmerPhase ? 0.4 : 1)

                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.rpSurfaceAlt.opacity(0.85))
                        .frame(height: baseSize * 0.14)
                        .overlay(
                            HStack(spacing: .rpSpaceXS) {
                                Circle()
                                    .fill(Color.rpAccent)
                                    .frame(width: baseSize * 0.06)

                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.rpSurface)
                                    .frame(height: baseSize * 0.06)
                                    .overlay(
                                        Capsule()
                                            .fill(Color.rpPrimary.opacity(0.7))
                                            .frame(width: baseSize * 0.28, height: baseSize * 0.04)
                                            .opacity(reduceMotion ? 1 : shimmerPhase ? 0.35 : 1)
                                            .animation(.rp(.standard, reduceMotion: reduceMotion), value: shimmerPhase)
                                    )
                            }
                            .padding(.horizontal, .rpSpaceS)
                        )
                }
                .foregroundStyle(Color.rpTextInverse)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scaleEffect(isAppeared ? 1 : 0.86)
            .offset(y: floatUp ? -6 : 6)
            .opacity(isAppeared ? 1 : 0)
            .animation(.rp(.standard, reduceMotion: reduceMotion), value: isAppeared)
            .animation(.rp(.relaxed, reduceMotion: reduceMotion).repeatForever(autoreverses: true), value: floatUp)
            .animation(.linear(duration: reduceMotion ? 0 : 2.4).repeatForever(autoreverses: true), value: shimmerPhase)
            .animation(.linear(duration: reduceMotion ? 0 : 4).repeatForever(autoreverses: false), value: sparkleRotation)
            .accessibilityHidden(true)
        }
        .onAppear(perform: startAnimations)
    }

    private var heroGradient: LinearGradient {
        LinearGradient(
            colors: [Color.rpPrimary, Color.rpAccent.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func startAnimations() {
        guard !isAppeared else { return }
        isAppeared = true

        guard reduceMotion == false else { return }

        floatUp = true
        shimmerPhase.toggle()
        sparkleRotation = 360
    }

    private struct CardShape: Shape {
        func path(in rect: CGRect) -> Path {
            Path(roundedRect: rect, cornerRadius: rect.width * 0.08, style: .continuous)
        }
    }
}

#Preview("Launch – Compact") {
    let provider = InterfaceProvider()
    return LaunchView()
        .environment(\.adaptiveLayoutContext, .fallback)
        .environmentObject(provider)
        .interface(provider)
}

#Preview("Launch – Expanded") {
    let provider = InterfaceProvider()
    let expanded = AdaptiveLayoutContext(
        breakpoint: .expanded,
        idiom: .pad,
        isLandscape: true,
        width: 1024,
        height: 768
    )
    return LaunchView()
        .environment(\.adaptiveLayoutContext, expanded)
        .environmentObject(provider)
        .interface(provider)
}

#Preview("Launch – Reduce Motion Dark") {
    let provider = InterfaceProvider(colorScheme: .dark, reduceMotion: true)
    return LaunchView()
        .environment(\.adaptiveLayoutContext, .fallback)
        .environmentObject(provider)
        .interface(provider)
        .preferredColorScheme(.dark)
}
