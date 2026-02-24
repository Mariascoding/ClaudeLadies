# ClaudeApp — Cycle Wellness Companion

## Overview

A cycle-tracking and wellness iOS app that provides daily phase-based guidance, symptom pattern analysis, nutrition protocol recommendations, nervous system support, and health device integration (Apple Health + Oura Ring).

## Build & Run

- **Xcode**: 16.4+
- **iOS target**: 18.5+
- **Swift**: 5.0
- **Dependencies**: Supabase SDK (Swift Package Manager)
- **Build**: `xcodebuild -project ClaudeApp.xcodeproj -scheme ClaudeApp -destination 'platform=iOS Simulator,name=iPhone 16'`
- **Project uses Xcode 16 file system sync** (`PBXFileSystemSynchronizedRootGroup`) — new files in `ClaudeApp/` are automatically included. Do NOT add manual PBXFileReference/PBXBuildFile entries for Swift files.

## Architecture

**MVVM + SwiftData + Environment injection**

```
ClaudeApp/
├── ClaudeAppApp.swift              # @main entry, model container, environment injection
├── ContentView.swift               # Tab navigation (Today, Log, Nourish, Insights, Settings)
├── Theme/                          # Design system tokens
├── Models/                         # SwiftData @Model classes + enums
├── Services/                       # AuthenticationService, Health/
├── ViewModels/                     # @Observable view models + CycleCalculator
├── Views/                          # SwiftUI views by tab
│   ├── Today/
│   ├── Log/
│   ├── Nourish/
│   ├── Insights/
│   ├── Settings/
│   ├── Shared/                     # Reusable components
│   └── MoonView/                   # Moon phase display
└── Content/                        # Pure logic engines + static content
    ├── PatternAnalysisEngine.swift  # Symptom clustering + protocol recommendations
    ├── GuidanceEngine.swift         # Daily phase-based guidance
    └── *Content.swift              # Static content data
```

## Key Patterns

### Environment Injection
Services are `@State` in `ClaudeAppApp` and injected via `.environment()`:
```swift
@Environment(AuthenticationService.self) private var authService
@Environment(HealthDataManager.self) private var healthManager
@Environment(\.modelContext) private var modelContext
```

### ViewModel Loading
All ViewModels are `@Observable`. Views create them as `@State` and load with modelContext:
```swift
@State private var viewModel = TodayViewModel()
.onAppear { viewModel.load(modelContext: modelContext) }
```

### Cross-View Sync
Use `Notification.Name.cycleDataDidChange` for cross-tab state updates:
```swift
// Post after mutations:
NotificationCenter.default.post(name: .cycleDataDidChange, object: nil)
// Listen in views:
.onReceive(NotificationCenter.default.publisher(for: .cycleDataDidChange)) { _ in viewModel.refresh() }
```

### SwiftData Enums
Enums stored as raw strings (`symptomsRaw`, `nervousSystemStateRaw`, etc.) with computed property accessors for type safety.

### Date Handling
All dates normalized to start-of-day: `Calendar.current.startOfDay(for: date)`. Period endDate is inclusive.

## Design System

### Spacing (`AppTheme.Spacing`)
`xs: 4` · `sm: 8` · `md: 16` · `lg: 24` · `xl: 32` · `xxl: 48`

### Corner Radius (`AppTheme.Radius`)
`sm: 8` · `md: 12` · `lg: 20` · `xl: 28` · `pill: 100`

### Colors
| Token | Usage |
|-------|-------|
| `Color.appRose` | Primary accent (menstrual phase) |
| `Color.appSage` | Growth/calm (follicular phase) |
| `Color.appTerracotta` | Energy/action (ovulation phase) |
| `Color.appSoftBrown` | Text/stability (luteal phase) |
| `Color.appCream` | Background (theme-dependent) |
| `Color.appWarmWhite` | Card background (theme-dependent) |

### Typography Modifiers
- `.warmTitle()` — title2, rounded, semibold
- `.warmHeadline()` — headline, rounded, medium
- `.guidanceText()` — body, serif, 85% opacity
- `.captionStyle()` — caption, rounded, 60% opacity
- `.affirmationStyle()` — title3, serif, italic, 80% opacity

### Card Pattern
All cards use the `.warmCard()` modifier. Cards with text-only content need `.frame(maxWidth: .infinity, alignment: .leading)` before `.warmCard()` to ensure full-width:
```swift
VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
    // content
}
.frame(maxWidth: .infinity, alignment: .leading)  // needed for text-only cards
.warmCard()
.padding(.horizontal, AppTheme.Spacing.md)
```

### Themes
5 color themes (classic, winter, spring, summer, autumn) + auto mode that maps cycle phase to season. Stored in `UserDefaults` keys `appColorTheme` and `appResolvedTheme`.

## Data Models

| Model | Purpose |
|-------|---------|
| `CycleLog` | Period start/end dates, cascade to SymptomEntry |
| `SymptomEntry` | Daily symptoms, nervous system state, custom tags |
| `UserProfile` | Cycle/period length, wellness goal, nutrition protocol |
| `NutritionLog` | Daily nutrition checklist items |
| `HealthMetricLog` | Cached health device data (sleep, HRV, HR, temp, steps) |

## Health Integration

`HealthDataManager` coordinates multiple providers via `HealthDataProvider` protocol:
- **AppleHealthProvider** — HealthKit (local, sleep stages, HRV, resting HR, basal temp, steps)
- **OuraProvider** — OAuth + REST API (remote, sleep, readiness, heart rate, activity)

Adding a new device = implement `HealthDataProvider` + register in `HealthDataManager.init()`.

Oura credentials are placeholder values (`YOUR_OURA_CLIENT_ID` / `YOUR_OURA_CLIENT_SECRET` in `OuraProvider.swift`).

## Content Engines

- **PatternAnalysisEngine** — Static functions. Analyzes symptom clusters (hormonal, inflammation, histamine, nervous system), recommends nutrition protocols, correlates health metrics with cycle phases. Requires 10+ entries over 14+ days.
- **GuidanceEngine** — Generates daily guidance with phase-specific affirmations, protect messages, decision timing, and nervous system exercises.
- **CycleCalculator** — Determines cycle position (phase, day in cycle) and phase boundaries.
