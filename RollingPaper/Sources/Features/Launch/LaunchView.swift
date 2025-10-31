import SwiftUI

struct LaunchView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isExpanded: Bool { horizontalSizeClass == .regular }
    private var metrics: LaunchMetrics { LaunchMetrics(isExpanded: isExpanded) }

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: metrics.stackSpacing) {
                LaunchHeroView(reduceMotion: reduceMotion)
                    .frame(maxWidth: metrics.heroWidth)
                    .frame(height: metrics.heroHeight)
                    .accessibilityHidden(true)

                VStack(spacing: .rpSpaceM) {
                    Text("RollingPaper")
                        .font(isExpanded ? Typography.largeTitle : Typography.title2)

                    Text("Loading your papers…")
                        .font(Typography.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .accessibilityLabel("앱 환경을 불러오는 중")
                        .accessibilityHint("잠시 후 로그인 화면으로 이동합니다")

                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.large)
                        .padding(.top, 6)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, metrics.contentPadding)
            .padding(.vertical, metrics.contentPadding)
            .background(
                RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                    .fill(.regularMaterial)
            )
            .shadow(color: Color.black.opacity(0.18), radius: metrics.shadowRadius, y: metrics.shadowYOffset)
            .padding(metrics.containerPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    private var backgroundGradient: some View {
        let primary = Color.accentColor
        let background = Color(.systemBackground)
        let colors: [Color] = colorScheme == .dark
            ? [background, primary.opacity(OpacityTokens.light)]
            : [primary.opacity(0.22), background]

        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay(Color.black.opacity(colorScheme == .dark ? 0.15 : 0))
    }
}

private struct LaunchMetrics {
    let stackSpacing: CGFloat
    let containerPadding: CGFloat
    let contentPadding: CGFloat
    let heroWidth: CGFloat
    let heroHeight: CGFloat
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let shadowYOffset: CGFloat

    init(isExpanded: Bool) {
        if isExpanded {
            stackSpacing = 48
            containerPadding = 48
            contentPadding = 36
            heroWidth = 360
            heroHeight = 280
            cornerRadius = 40
            shadowRadius = 28
            shadowYOffset = 16
        } else {
            stackSpacing = 32
            containerPadding = 24
            contentPadding = 28
            heroWidth = 280
            heroHeight = 220
            cornerRadius = 28
            shadowRadius = 20
            shadowYOffset = 12
        }
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
                    .fill(Color(.systemBackground))
                    .frame(width: baseSize * 0.72, height: baseSize * 0.56)
                    .offset(x: -baseSize * 0.08, y: baseSize * 0.04)
                    .opacity(0.85)

                CardShape()
                    .stroke(Color.primary.opacity(0.08), lineWidth: 2)
                    .frame(width: baseSize * 0.68, height: baseSize * 0.52)
                    .offset(x: baseSize * 0.06, y: -baseSize * 0.05)

                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: baseSize * 0.22, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                        .rotationEffect(.degrees(sparkleRotation))
                        .opacity(reduceMotion ? 0.9 : shimmerPhase ? 0.4 : 1)

                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemBackground).opacity(0.9))
                        .frame(height: baseSize * 0.14)
                        .overlay(
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: baseSize * 0.06)

                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(.systemBackground))
                                    .frame(height: baseSize * 0.06)
                                    .overlay(
                                        Capsule()
                                            .fill(Color.accentColor.opacity(0.7))
                                            .frame(width: baseSize * 0.28, height: baseSize * 0.04)
                                            .opacity(reduceMotion ? 1 : shimmerPhase ? 0.35 : 1)
                                            .animation(reduceMotion ? nil : .linear(duration: 2.2).repeatForever(autoreverses: true), value: shimmerPhase)
                                    )
                            }
                            .padding(.horizontal, 12)
                        )
                }
                .foregroundStyle(Color.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scaleEffect(isAppeared ? 1 : 0.86)
            .offset(y: floatUp ? -6 : 6)
            .opacity(isAppeared ? 1 : 0)
            .animation(.easeInOut(duration: 0.35), value: isAppeared)
            .animation(reduceMotion ? nil : .easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: floatUp)
            .animation(reduceMotion ? nil : .linear(duration: 2.6).repeatForever(autoreverses: true), value: shimmerPhase)
            .animation(reduceMotion ? nil : .linear(duration: 5).repeatForever(autoreverses: false), value: sparkleRotation)
            .accessibilityHidden(true)
        }
        .onAppear(perform: startAnimations)
    }

    private var heroGradient: LinearGradient {
        LinearGradient(
            colors: [Color.accentColor, Color.accentColor.opacity(0.6)],
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
    LaunchView()
}

#Preview("Launch – Expanded") {
    LaunchView()
}

#Preview("Launch – Reduce Motion Dark") {
    LaunchView()
        .preferredColorScheme(.dark)
}
