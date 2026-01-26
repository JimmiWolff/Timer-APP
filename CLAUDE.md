# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CircuitTimer is a native iOS circuit training timer app built with SwiftUI. It features Live Activities (Lock Screen + Dynamic Island), audio ducking for workout beeps, and background-safe timing using date-based calculations.

**Key Technical Decisions:**
- **Date-based timer**: Uses target end dates instead of counting down to survive iOS background suspension
- **Audio ducking**: AVAudioSession with `.playback + .duckOthers` to lower other apps' volume during beeps
- **Live Activities**: ActivityKit integration for Lock Screen and Dynamic Island display

## Git Workflow

**IMPORTANT: Always develop on a feature branch, never directly on main.**

Before starting any code changes:
1. Create a new branch: `git checkout -b feature/<descriptive-name>` or `fix/<descriptive-name>`
2. Make changes and commit incrementally
3. Only merge to main after user confirms testing is complete
4. Push the branch for backup: `git push -u origin <branch-name>`

Example workflow:
```bash
git checkout -b fix/pause-resume-sync
# ... make changes ...
git add . && git commit -m "Fix pause/resume notification sync"
# ... user tests and confirms ...
git checkout main && git merge fix/pause-resume-sync
git push origin main
```

## Build Commands

```bash
# Build for iOS device (no code signing)
xcodebuild -project CircuitTimer.xcodeproj -scheme CircuitTimer -configuration Debug build CODE_SIGNING_ALLOWED=NO

# Build for simulator
xcodebuild -project CircuitTimer.xcodeproj -scheme CircuitTimer -sdk iphonesimulator build

# Clean build
xcodebuild -project CircuitTimer.xcodeproj -scheme CircuitTimer clean

# Run tests
./scripts/run-tests.sh
# Or manually:
xcodebuild test -project CircuitTimer.xcodeproj -scheme CircuitTimer -destination 'platform=iOS Simulator,name=iPhone 17' -quiet
```

## Testing

### Pre-commit Hook
A pre-commit hook is installed that:
- On **main branch**: Runs the full test suite before allowing commits
- On **feature branches**: Runs a quick build check

If tests fail, the commit is aborted. Fix the failing tests before committing.

### Test Suites
- **TimerEngineTests**: Core date-based timer logic
- **TimerConfigurationTests**: Workout configuration validation and calculations
- **TimerStateTests**: State machine properties and transitions
- **TimerViewModelTests**: Main orchestration layer

### Running Tests Manually
```bash
# Quick test run
./scripts/run-tests.sh

# Verbose output
xcodebuild test -project CircuitTimer.xcodeproj -scheme CircuitTimer -destination 'platform=iOS Simulator,name=iPhone 17'
```

**Open in Xcode:**
```bash
open CircuitTimer.xcodeproj
```

## Web Prototype (crossfit-timer-web/)

React web application for UI/UX prototyping before Swift translation.

```bash
cd crossfit-timer-web
npm install
npm run dev      # Development server at http://localhost:5173
npm run build    # Production build
```

## Architecture

### MVVM with Service Layer

```
Views (SwiftUI)
    ↓ observes @Published
TimerViewModel (single source of truth)
    ↓ coordinates
Services (TimerEngine, AudioManager, LiveActivityManager, BackgroundUpdateScheduler)
```

### Key Components

**TimerViewModel** (`ViewModels/TimerViewModel.swift`):
- Orchestrates timer, audio, and Live Activity services
- Manages state machine: idle → work ↔ rest → restBetweenSets → finished
- Handles pause/resume from both app UI and Live Activity controls
- `synchronizeState()` catches up on missed transitions when app foregrounds

**TimerEngine** (`Services/TimerEngine.swift`):
- Core date-based timer logic
- Stores `intervalEndDate` instead of counting down
- Survives iOS suspension—calculates remaining time on demand

**LiveActivityManager** (`Services/LiveActivityManager.swift`):
- Manages ActivityKit lifecycle (start, update, end)
- Contains `CircuitTimerAttributes` struct for Live Activity data
- File must be shared between main app and widget extension targets

**BackgroundUpdateScheduler** (`Services/BackgroundUpdateScheduler.swift`):
- Schedules local notifications at state transition times
- Wakes app to update Live Activities during suspension

**SharedDataManager** (`Services/SharedDataManager.swift`):
- Cross-process communication between main app and widget extension
- Uses App Groups (`group.wolff.circuittimer`) with shared UserDefaults
- Widget extension writes pause/resume commands, main app polls and executes
- Required because NotificationCenter doesn't work across processes

**Widget Extension** (`CircuitTimerLiveActivity/`):
- `CircuitTimerLiveActivity.swift`: Lock Screen and Dynamic Island UI
- `PauseResumeIntent.swift`: AppIntent for Lock Screen pause/resume button

### State Machine

`TimerState` enum:
- `.idle` → `.work` → `.rest` → `.work` ... → `.restBetweenSets` → `.work` ... → `.finished`
- `.paused` can be entered from any active state

### Targets

1. **CircuitTimer**: Main iOS app
2. **CircuitTimerLiveActivity**: Widget extension for Live Activities
3. **CircuitTimerTests**: Unit tests
4. **CircuitTimerUITests**: UI tests

**Critical:** `LiveActivityManager.swift` must have target membership in BOTH CircuitTimer and CircuitTimerLiveActivity for `CircuitTimerAttributes` access.

## iOS Requirements

- **Minimum iOS**: 16.1 (required for Live Activities)
- **Dynamic Island**: iPhone 14 Pro+ only
- **Device testing required**: Live Activities, audio ducking, and background timing cannot be fully tested in simulator

## Xcode Capabilities Required

- Push Notifications (for Live Activities authorization)
- Background Modes → Audio, AirPlay, and Picture in Picture
- App Groups → `group.wolff.circuittimer` (BOTH main app and widget extension targets)

## Info.plist Keys

```xml
<key>NSSupportsLiveActivities</key>
<true/>
<key>NSSupportsLiveActivitiesFrequentUpdates</key>
<true/>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```
