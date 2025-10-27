# Rolling Paper - Gesture System Analysis & Refactoring Plan

**Date**: October 27, 2025  
**Status**: Critical Issues Identified - Refactoring Required  
**Severity**: HIGH (Core Functionality Broken)

---

## Executive Summary

The RollingPaper application has **three critical gesture-related issues** that prevent core functionality from working correctly:

1. **Edit Mode Exit Failure**: LongPress on stickers in edit mode doesn't trigger exit
2. **Unintended Edit Mode Activation**: Pan gesture in default mode incorrectly enters edit mode
3. **Unintended Edit Mode Activation**: Pinch zoom in default mode incorrectly enters edit mode

These issues stem from **fundamental gesture coordination and priority conflicts** in the current architecture. The gesture system requires a complete redesign using modern iOS best practices.

---

## Current Architecture Analysis

### Problem 1: Edit Mode Exit Failure

**Location**: `PaperView.swift` (lines 105-114)

```swift
let editingOverlay = Color.clear
    .contentShape(Rectangle())
    .simultaneousGesture(
        editingCompositeGesture,
        isEnabled: canvasStore.isEditing
    )
    .onLongPressGesture(
        minimumDuration: 0.6,
        maximumDistance: 10,
        perform: {},  // ← PROBLEM: Does nothing!
        onPressingChanged: { isPressing in
            guard canvasStore.isEditing else { return }
            isPressingToExit = isPressing
        }
    )
```

**Root Cause**:
- The `onLongPressGesture` has an empty `perform: {}` closure
- When the overlay is a `Color.clear`, it may not properly capture touches on sticker areas
- The `editingOverlay` is drawn on top but LongPress on stickers might be consumed by the sticker view itself
- Z-index and hit testing aren't properly managed

**Current Behavior**:
- User long-presses a sticker in edit mode
- `isPressingToExit` becomes true
- But the `onChange` handler (line 134-141) should exit, yet doesn't always work
- Sticker editing gestures continue to respond

---

### Problem 2: Default Mode Pan Triggers Edit

**Location**: `PaperView.swift` (lines 153-181)

```swift
private var panGesture: some Gesture {
    DragGesture(minimumDistance: 40, coordinateSpace: .local)
        .onChanged { value in
            guard canvasStore.isEditing == false else { return }
            // ... pan logic
        }
}
```

**Location**: `PaperCanvasView.swift` (lines 151-167)

```swift
private var activationGesture: some Gesture {
    LongPressGesture(minimumDuration: 0.4, maximumDistance: 20)
        .onChanged { isPressing in
            guard isPressing else { return }
            if store.isEditing {
                guard isSelected else { return }
                return  // ← This should prevent entering edit mode, but...
            }
            // ... enters edit mode
        }
}
```

**Root Cause**:
- Pan gesture has `minimumDistance: 40` (requires 40pt movement)
- Sticker LongPress has `minimumDuration: 0.4` (requires 0.4 seconds)
- iOS gesture recognizers can fire multiple gestures in parallel
- When user tries to pan the canvas, finger movement might be slow enough that LongPress recognizes first
- The LongPress completes before the pan gesture accumulates 40 points of movement
- This causes unintended edit mode activation

**Current Behavior**:
1. User starts panning with slow finger movement
2. After 0.4 seconds, sticker LongPress recognizes
3. Sticker enters edit mode
4. Canvas pan gesture never gets recognized

---

### Problem 3: Default Mode Pinch Triggers Edit

**Location**: `PaperView.swift` (lines 88-91)

```swift
.simultaneousGesture(
    panGesture.simultaneously(with: zoomGesture),
    isEnabled: !canvasStore.isEditing
)
```

**Location**: `PaperCanvasView.swift` (lines 151-167)

```swift
.highPriorityGesture(activationGesture, isEnabled: !store.isEditing)
```

**Root Cause**:
- Canvas uses `simultaneousGesture` with zoom gesture
- Sticker uses `highPriorityGesture` for activation
- These gesture modifiers have conflicting semantics
- When user pinches near a sticker, both sticker LongPress and canvas zoom try to recognize
- `highPriorityGesture` intercepts touches before `simultaneousGesture` can work
- Sticker LongPress fires even though intent was to zoom the canvas

**Current Behavior**:
1. User attempts pinch zoom on canvas near sticker
2. Sticker's `highPriorityGesture` LongPress recognizes
3. Edit mode activates instead of zooming
4. Canvas zoom never gets recognized

---

## iOS Gesture Best Practices (2024)

### Core Principles

1. **Gesture Priority Hierarchy**
   - More specific gestures should take priority over general ones
   - Use `highPriorityGesture` for specific taps/selections
   - Use `simultaneousGesture` for multi-touch operations (pan + zoom)

2. **State-Based Gesture Recognition**
   - Always check state before recognizing gestures
   - Use boolean guards in `onChanged` callbacks
   - Use `isEnabled` parameter to completely disable gestures

3. **Mutual Exclusivity**
   - Use `exclusiveGesture` when two gestures cannot both succeed
   - Avoid overlapping hit areas
   - Clear z-index management for layered gestures

4. **Gesture Coordination**
   - Compose related gestures using `simultaneously(with:)` or `sequenced(before:)`
   - Maintain separate state for each gesture type
   - Reset state on `onEnded` callbacks

---

## Proposed Solution: State Machine Architecture

### 1. Gesture Coordination Manager

A centralized manager that controls all gesture recognition based on application state:

```swift
enum PaperMode {
    case default
    case selection(stickerID: UUID)
    case editing(stickerID: UUID)
}

@MainActor
class GestureCoordinationManager: ObservableObject {
    @Published var currentMode: PaperMode = .default
    
    // Gesture availability matrix
    func canRecognizePan() -> Bool { currentMode == .default }
    func canRecognizePinch() -> Bool { currentMode == .default }
    func canRecognizeSelection(sticker: UUID) -> Bool { currentMode == .default }
    func canRecognizeEditActivation(sticker: UUID) -> Bool {
        if case .selection(let id) = currentMode, id == sticker { return true }
        return false
    }
    func canRecognizeStopEditing() -> Bool {
        if case .editing = currentMode { return true }
        return false
    }
}
```

### 2. Gesture Layers (Priority Order)

**Layer 1 - Canvas Interactions (Default Mode Only)**
- Pan: Move canvas (minimumDistance: 50, 400ms threshold)
- Pinch: Zoom canvas (simultaneous with pan)
- When any canvas gesture starts, other gestures disabled

**Layer 2 - Sticker Selection (Default Mode)**
- Tap sticker: Select sticker → Selection mode
- Only recognized when canvas gestures not active

**Layer 3 - Edit Activation (Selection Mode)**
- LongPress selected sticker: → Edit mode (0.6s)
- Only on the specific selected sticker

**Layer 4 - Sticker Editing (Edit Mode)**
- Drag: Move sticker
- Pinch/Magnification: Resize
- Rotation: Rotate sticker
- All work simultaneously with each other

**Layer 5 - Edit Exit (Edit Mode)**
- LongPress on empty area: Exit edit mode
- Returns to Default mode, clears selection

### 3. State Machine Flow

```
┌─────────────────┐
│ DEFAULT MODE    │
│ Pan/Zoom canvas │
│ Can tap sticker │
└────────┬────────┘
         │
         │ [Tap sticker]
         │
         ▼
┌─────────────────────┐
│ SELECTION MODE      │
│ Sticker selected    │
│ Show visual marker  │
│ Can longpress       │
└────────┬────────────┘
         │
         │ [LongPress sticker]
         │
         ▼
┌─────────────────────┐
│ EDITING MODE        │
│ Drag/Scale/Rotate   │
│ Show editing UI     │
│ Can exit with LP    │
└────────┬────────────┘
         │
         │ [LongPress empty]
         │
         └──────────────────┐
                            │
         [Tap delete] ──────┤
                            │
         ┌──────────────────┘
         │
         ▼
    [Cleared]
    [Back to DEFAULT]
```

---

## Implementation Strategy

### Phase 1: Foundation
- [ ] Create `GestureCoordinationManager` with state machine
- [ ] Define gesture availability matrix
- [ ] Create comprehensive gesture state models

### Phase 2: Canvas Gestures
- [ ] Refactor pan gesture with proper state checks
- [ ] Refactor zoom gesture with proper state checks
- [ ] Implement gesture exclusivity (pan+zoom simultaneous, but not with sticker gestures)

### Phase 3: Sticker Interaction
- [ ] Refactor sticker selection (tap only in default mode)
- [ ] Implement edit activation (longpress only when selected)
- [ ] Fix sticker editing composite gestures
- [ ] Implement background longpress for exit

### Phase 4: Integration & Testing
- [ ] Integrate all components into PaperView
- [ ] Add visual feedback for state transitions
- [ ] Implement comprehensive gesture testing
- [ ] Test edge cases (rapid mode switching, conflicting inputs)

---

## Key Implementation Details

### Fix for Problem 1: Edit Mode Exit

```swift
// Use a background view with hit testing and proper z-index
let backgroundGesture = Color.clear
    .contentShape(Rectangle())
    .highPriorityGesture(
        LongPressGesture(minimumDuration: 0.6, maximumDistance: 10)
            .onEnded { _ in
                guard gestureManager.currentMode == .editing else { return }
                withAnimation {
                    gestureManager.exitEditMode()
                }
            }
    )
    .allowsHitTesting(gestureManager.currentMode == .editing)
```

### Fix for Problem 2: Default Mode Pan Blocks Edit

```swift
// Use exclusiveGesture to prevent both pan and sticker selection
let canvasGestures = panGesture.exclusively(before: zoomGesture)

// Sticker gesture only active if canvas gesture not active
let stickerGestures = activationGesture
    .onChanged { isPressing in
        guard isPressing else { return }
        guard !gestureManager.isCanvasInteracting else { return }  // ← KEY FIX
        gestureManager.selectSticker(sticker.id)
    }
```

### Fix for Problem 3: Pinch Doesn't Trigger Edit

```swift
// Clear priority rules: zoom only works in default mode
private var zoomGesture: some Gesture {
    MagnificationGesture()
        .onChanged { value in
            guard gestureManager.currentMode == .default else { return }  // ← KEY FIX
            // ... zoom logic
        }
}

// Sticker longpress incompatible with pinch
.highPriorityGesture(
    activationGesture,
    isEnabled: gestureManager.currentMode == .default  // ← KEY FIX
)
```

---

## Testing Strategy

### Unit Tests
1. State machine transitions
2. Gesture availability matrix
3. Mode logic validation

### Integration Tests
1. Pan in default mode (should not enter edit)
2. Pinch in default mode (should not enter edit)
3. Tap sticker → selection state
4. LongPress selected sticker → edit state
5. LongPress empty area in edit → default state
6. All editing gestures work in edit mode only
7. Rapid mode transitions don't crash
8. Delete in edit mode works correctly

### Manual Testing
1. Slow pan on canvas (shouldn't enter edit)
2. Fast pinch zoom near sticker (should zoom, not edit)
3. LongPress sticker, then try to pan (should exit)
4. Edit multiple stickers in sequence
5. Verify haptic feedback at each transition

---

## Success Criteria

- ✅ LongPress on sticker in edit mode exits edit mode (Problem 1 Fixed)
- ✅ Pan canvas in default mode does NOT trigger edit mode (Problem 2 Fixed)
- ✅ Pinch zoom in default mode does NOT trigger edit mode (Problem 3 Fixed)
- ✅ Clear state machine with defined transitions
- ✅ No conflicting gesture recognizers
- ✅ Smooth animations and haptic feedback
- ✅ All tests passing

---

## References

- iOS Gesture Recognizer Documentation
- SwiftUI Gesture API Reference
- Modern UIKit Gesture Best Practices (2024)
- RollingPaper Codebase Analysis

---

## Timeline

- **Phase 1**: 1-2 hours
- **Phase 2**: 1 hour
- **Phase 3**: 1.5-2 hours
- **Phase 4**: 1-1.5 hours
- **Total**: 4-6 hours focused development

**Estimated Start**: Immediate
**Priority**: Critical (blocks core functionality)
