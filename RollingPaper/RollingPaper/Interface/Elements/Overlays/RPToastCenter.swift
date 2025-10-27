import Combine
import SwiftUI
import UIKit

public final class RPToastCenter: ObservableObject {
    public static let shared = RPToastCenter()

    @Published public private(set) var currentToast: RPToast?

    private var dismissWorkItem: DispatchWorkItem?

    public init() {}

    public func show(_ toast: RPToast, duration: TimeInterval = 3.0) {
        dismissWorkItem?.cancel()
        withAnimation(.rp(.standard, reduceMotion: UIAccessibility.isReduceMotionEnabled)) {
            currentToast = toast
        }

        guard duration > 0 else { return }

        let workItem = DispatchWorkItem { [weak self] in
            self?.dismiss(animated: true)
        }
        dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
    }

    public func dismiss(animated: Bool = true) {
        dismissWorkItem?.cancel()
        dismissWorkItem = nil

        if animated {
            withAnimation(.rp(.fast, reduceMotion: UIAccessibility.isReduceMotionEnabled)) {
                currentToast = nil
            }
        } else {
            currentToast = nil
        }
    }
}
