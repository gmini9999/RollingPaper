import Combine
import SwiftUI

public final class InterfaceProvider: ObservableObject {
    @Published public private(set) var colorScheme: ColorScheme
    @Published public private(set) var reduceMotion: Bool
    @Published public private(set) var dynamicType: DynamicTypeSize

    public init(colorScheme: ColorScheme = .light,
                reduceMotion: Bool = false,
                dynamicType: DynamicTypeSize = .large) {
        self.colorScheme = colorScheme
        self.reduceMotion = reduceMotion
        self.dynamicType = dynamicType
    }

    @MainActor
    public func set(colorScheme: ColorScheme) {
        guard colorScheme != self.colorScheme else { return }
        self.colorScheme = colorScheme
    }

    @MainActor
    public func set(reduceMotion: Bool) {
        guard reduceMotion != self.reduceMotion else { return }
        self.reduceMotion = reduceMotion
    }

    @MainActor
    public func set(dynamicType: DynamicTypeSize) {
        guard dynamicType != self.dynamicType else { return }
        self.dynamicType = dynamicType
    }
}

private struct InterfaceKey: EnvironmentKey {
    static let defaultValue = InterfaceProvider()
}

public extension EnvironmentValues {
    var interface: InterfaceProvider {
        get { self[InterfaceKey.self] }
        set { self[InterfaceKey.self] = newValue }
    }
}

public extension View {
    func interface(_ provider: InterfaceProvider) -> some View {
        environment(\.interface, provider)
    }
}

