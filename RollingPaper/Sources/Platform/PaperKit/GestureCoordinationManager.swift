import Combine
import SwiftUI
import UIKit

// MARK: - PaperMode Enum

/// Defines the two primary modes of interaction in the Paper canvas.
enum PaperMode: Equatable, Sendable {
    /// Default mode: Canvas can be panned and zoomed
    case `default`
    /// Editing mode: A sticker is actively being edited (moved, scaled, rotated)
    case editing
}

// MARK: - GestureCoordinationManager

/// Centralized manager that coordinates all gestures based on the current application mode.
/// Uses a state machine to control gesture recognition.
@MainActor
final class GestureCoordinationManager: ObservableObject {
    // MARK: - Published Properties
    
    /// The current mode of gesture interaction
    @Published private(set) var currentMode: PaperMode = .default
    
    /// The ID of the currently edited sticker (if any)
    @Published private(set) var selectedStickerId: UUID?
    
    /// Indicates if any canvas gesture is currently in progress
    @Published private(set) var isCanvasInteracting: Bool = false
    
    // MARK: - Haptic Feedback
    
    private let hapticEngine: RPHapticTriggering
    
    // MARK: - Initialization
    
    init(hapticEngine: RPHapticTriggering) {
        self.hapticEngine = hapticEngine
    }
    
    convenience init() {
        self.init(hapticEngine: RPHapticEngine.shared)
    }
    
    func prepareHapticEngine() {
        hapticEngine.prepare()
    }
    
    // MARK: - State Transition Methods
    
    /// Enters editing mode for the specified sticker.
    /// - Parameter stickerId: The UUID of the sticker to edit
    func enterEditMode(for stickerId: UUID) {
        guard currentMode == .default else { return }
        
        isCanvasInteracting = false
        selectedStickerId = stickerId
        currentMode = .editing
        hapticEngine.trigger(.impact(style: .medium))
    }
    
    /// Exits editing mode and returns to default mode.
    func exitEditMode() {
        guard currentMode == .editing else { return }
        
        currentMode = .default
        selectedStickerId = nil
        isCanvasInteracting = false
        hapticEngine.trigger(.impact(style: .light))
    }
    
    // MARK: - Canvas Gesture State
    
    /// Marks the start of a canvas gesture (pan or zoom).
    func beginCanvasGesture() {
        isCanvasInteracting = true
    }
    
    /// Marks the end of a canvas gesture.
    func endCanvasGesture() {
        isCanvasInteracting = false
    }
    
    // MARK: - Gesture Availability
    
    /// Canvas pan and zoom gestures are enabled in default mode only.
    var canPerformCanvasGestures: Bool {
        currentMode == .default
    }
    
    /// Sticker editing gestures are enabled in editing mode only.
    var canPerformStickerEditing: Bool {
        currentMode == .editing
    }
    
    /// Checks if a specific sticker is currently being edited.
    func canEditSticker(_ stickerId: UUID) -> Bool {
        currentMode == .editing && selectedStickerId == stickerId
    }
    
}
