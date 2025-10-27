# RollingPaper

SwiftUI-first prototype for crafting and sharing digital rolling papers across iPhone and iPad. The project focuses on delivering a complete end-to-end interaction journey (launch → auth → home → editor → share) with adaptive layouts, accessibility support, and reusable design tokens before any backend integration begins.

## Project Highlights

- **Universal SwiftUI navigation** covering launch, authentication, home feed, paper editor, and share surfaces with iPhone/iPad specific layouts.
- **Interface design system** extracted into the `Interface` module (colors, typography, spacing, motion, haptics) to keep visuals cohesive.
- **Mock auth layer** (`MockAuthService`) and navigation coordinator to simulate future Firebase-backed sessions.
- **Adaptive layout engine** (`AdaptiveLayoutContext`) that switches between navigation stack and split view experiences.
- **Rich component library** (`RPButton`, `RPToast`, `RPCard`, etc.) ready for reuse across additional flows.

## Repository Layout

```
RollingPaper/
├─ RollingPaper.xcodeproj          # Xcode workspace & scheme
├─ RollingPaper/                   # Application sources
│  ├─ App/                         # App entry point & dependency wiring
│  ├─ Core/                        # Navigation, models, layout utilities
│  ├─ Features/                    # Feature-oriented SwiftUI flows
│  ├─ Interface/                   # Design system implementation
│  ├─ Resources/                   # Asset catalogs
│  └─ Services/                    # Mock services & protocols
└─ .taskmaster/docs/               # Planning docs & PRDs
```

## Getting Started

### Prerequisites

- Xcode 16 or later (iOS 18 SDK recommended)
- Swift 5.10 toolchain or newer
- macOS Sequoia (15.0+) for the latest SwiftUI previews

### Build & Run

1. Open `RollingPaper.xcodeproj` in Xcode.
2. Select the `RollingPaper` scheme.
3. Choose an iOS Simulator (iPhone 16 or iPad Pro 13-inch are good defaults).
4. Press **⌘R** to build and run.

The project relies entirely on mock data; no additional environment configuration is required.

## Development Notes

- **Accessibility**: Interface state reacts to `ColorScheme`, `DynamicTypeSize`, and the reduce-motion accessibility flag without relying on UIKit notifications.
- **State management**: View models use `ObservableObject` and `@StateObject`, keeping the UI preview-friendly and ready for Firebase integration.
- **Future roadmap**: Firebase Auth, Firestore, and Storage wiring will replace the mock services once UI acceptance criteria are met (see `.taskmaster/docs/rollingpaper-ui-first-prd.md`).

## Contributing

1. Fork the repository and create a feature branch.
2. Add or update SwiftUI components, keeping design tokens in sync.
3. Run the project in both light/dark modes and with different dynamic type settings.
4. Open a pull request with screenshots or screen recordings when possible.

## License

This project is currently proprietary. Please contact the maintainers before reusing any part of the codebase.

