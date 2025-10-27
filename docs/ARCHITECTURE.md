# RollingPaper Architecture

This document captures the new project layout after restructuring the app around presentation, domain, data, and shared layers. The structure follows the clean architecture guidance referenced from Context7 (`/nalexn/clean-architecture-swiftui`).

## Directory Overview

```
RollingPaper/
├─ docs/                     # Developer-facing documentation
├─ RollingPaper.xcodeproj/   # Xcode project
└─ Sources/
   ├─ Application/           # App bootstrap & navigation coordination
   │  ├─ App/                # `RollingPaperApp` entry point
   │  └─ Navigation/         # Routing, deep-link parsing, modal destinations
   ├─ Data/                  # Data access layer (network/db services)
   │  └─ Services/
   │     └─ Auth/            # Auth service + mock implementation
   ├─ Domain/                # Domain models shared across features
   │  └─ Models/
   ├─ Presentation/          # SwiftUI presentation layer organised per feature
   │  └─ Features/
   │     ├─ Auth/
   │     │  ├─ Components/
   │     │  ├─ ViewModels/
   │     │  └─ Views/
   │     ├─ Home/
   │     │  ├─ Components/
   │     │  ├─ Models/
   │     │  ├─ ViewModels/
   │     │  └─ Views/
   │     ├─ Launch/
   │     │  └─ Views/
   │     ├─ Paper/
   │     │  ├─ Components/
   │     │  ├─ Models/
   │     │  ├─ ViewModels/
   │     │  └─ Views/
   │     └─ Share/
   │        └─ Views/
   ├─ Resources/             # Asset catalogues & other bundled resources
   └─ Shared/                # Cross-cutting modules and design system
      ├─ DesignSystem/       # Foundations, elements, patterns, preview helpers
      ├─ Interactions/       # Haptics, feedback, animation helpers
      └─ Layout/             # Adaptive layout primitives
```

## Layer Responsibilities

- **Application**: owns app lifecycle, navigation stacks, and routing logic.
- **Presentation**: contains SwiftUI views, view models, and feature-specific UI components.
- **Domain**: keeps pure models (entities, value objects) shared between Presentation and Data layers.
- **Data**: provides services/repositories for persistence or networking; currently holds the authentication service implementations.
- **Shared**: centralises reusable design-system elements, interaction helpers, and layout utilities so that Presentation and Application layers can consume them without duplicating code.
- **Resources**: bundles static assets packaged with the app.

## Naming & Conventions

- Each feature folder contains `Views/`, `Components/`, `ViewModels/`, and optional `Models/` subdirectories.
- Cross-feature helpers (e.g., `RPButton`, `RPInteractionFeedbackCenter`) live under `Shared`.
- New modules or services should be added to the appropriate layer to keep responsibilities isolated.
- Tests should mirror this structure under a top-level `Tests/` folder (to be introduced in a subsequent iteration).

## Next Steps

- Audit Swift Package dependencies (none at this time) when new libraries are added.
- Introduce dedicated `Tests/` hierarchy aligned with `Sources/`.
- Continue pruning obsolete previews or demo assets that no longer support the core UX.


