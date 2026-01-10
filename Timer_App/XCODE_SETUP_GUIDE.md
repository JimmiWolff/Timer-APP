# Xcode Setup Guide for CircuitTimer

This guide explains how to set up the CircuitTimer iOS app in Xcode on macOS and import all the generated Swift files from this WSL/Linux environment.

---

## Prerequisites

- **macOS** with **Xcode 14.1+** installed
- **iOS 16.1+** target device or simulator
- **Apple Developer account** (free or paid) for device testing

---

## Step 1: Create New Xcode Project

1. Open Xcode on your Mac
2. Select **File → New → Project**
3. Choose **iOS** platform
4. Select **App** template
5. Click **Next**

### Project Configuration:

| Field | Value |
|-------|-------|
| Product Name | `CircuitTimer` |
| Team | Select your team |
| Organization Identifier | `com.yourteam` (use your own) |
| Interface | **SwiftUI** |
| Language | **Swift** |
| Storage | None |
| Include Tests | Optional |

6. Click **Next**
7. Choose save location
8. Click **Create**

---

## Step 2: Add Widget Extension Target (for Live Activities)

1. In Xcode, select **File → New → Target**
2. Search for and select **Widget Extension**
3. Click **Next**

### Widget Extension Configuration:

| Field | Value |
|-------|-------|
| Product Name | `CircuitTimerLiveActivity` |
| Team | Same as main app |
| Include Configuration Intent | **Uncheck** |
| **Include Live Activity** | **✅ CHECK THIS** (CRITICAL!) |

4. Click **Finish**
5. When prompted "Activate CircuitTimerLiveActivity scheme?", click **Activate**

---

## Step 3: Transfer Files from WSL to Mac

You need to transfer the generated Swift files from your WSL/Linux environment to your Mac.

### Option A: Using Git (Recommended)

```bash
# In WSL/Linux (in the Timer_App directory)
git init
git add CircuitTimer/ CircuitTimerLiveActivity/
git commit -m "Add CircuitTimer Swift files"
git remote add origin <your-github-repo-url>
git push -u origin main

# On Mac
git clone <your-github-repo-url>
```

### Option B: Using SCP/SFTP

```bash
# On Mac, from WSL directory via network
scp -r /path/to/Timer_App/CircuitTimer ~/Desktop/
scp -r /path/to/Timer_App/CircuitTimerLiveActivity ~/Desktop/
```

### Option C: Using OneDrive/Dropbox

1. Copy the `CircuitTimer/` and `CircuitTimerLiveActivity/` folders to OneDrive/Dropbox in WSL
2. Wait for sync
3. Access from Mac

### Option D: Direct File Copy (if dual-booting or VM)

Copy the folders directly using Finder or file explorer.

---

## Step 4: Import Swift Files into Xcode

### 4.1 Delete Default Files

First, delete the auto-generated files from Xcode:

1. In Project Navigator, select `ContentView.swift` (in main app)
2. Press **Delete** → Move to Trash
3. Select `CircuitTimerLiveActivity.swift` (in widget extension)
4. Press **Delete** → Move to Trash (we'll add our own version)

### 4.2 Import Main App Files

1. In Project Navigator, **right-click** on the **CircuitTimer** group (blue folder)
2. Select **Add Files to "CircuitTimer"...**
3. Navigate to your transferred `CircuitTimer/` folder
4. Select **ALL** files and folders:
   - Models/ folder
   - ViewModels/ folder
   - Services/ folder
   - Views/ folder
   - Utilities/ folder
   - CircuitTimerApp.swift

5. In the dialog, ensure:
   - ✅ **Copy items if needed** (check this)
   - ✅ **Create groups** (selected)
   - ✅ **CircuitTimer** target is checked
   - ❌ CircuitTimerLiveActivity target is NOT checked (except for shared files - see below)

6. Click **Add**

### 4.3 Import Widget Extension Files

1. In Project Navigator, **right-click** on the **CircuitTimerLiveActivity** group
2. Select **Add Files to "CircuitTimer"...**
3. Navigate to your transferred `CircuitTimerLiveActivity/` folder
4. Select **ALL** files:
   - CircuitTimerLiveActivity.swift
   - PauseResumeIntent.swift
   - CircuitTimerLiveActivityBundle.swift

5. In the dialog, ensure:
   - ✅ **Copy items if needed**
   - ✅ **Create groups**
   - ❌ CircuitTimer target is NOT checked
   - ✅ **CircuitTimerLiveActivity** target IS checked

6. Click **Add**

### 4.4 IMPORTANT: Remove LiveActivityManager Duplicate

**The `Services/LiveActivityManager.swift` file already contains `CircuitTimerAttributes`**, so we don't need a separate ActivityAttributes.swift file. The Attributes are defined within the LiveActivityManager file.

However, we need to make this file accessible to BOTH targets:

1. In Project Navigator, locate **Services/LiveActivityManager.swift**
2. Click on it to select
3. Open **File Inspector** (right panel, first tab with document icon)
4. Under **Target Membership**, check BOTH:
   - ✅ CircuitTimer
   - ✅ CircuitTimerLiveActivity

This allows both the main app and widget extension to access `CircuitTimerAttributes`.

---

## Step 5: Configure App Capabilities

### 5.1 Main App Target

1. In Project Navigator, click on the **CircuitTimer** project (blue icon at top)
2. Select **CircuitTimer** target (under TARGETS)
3. Go to **Signing & Capabilities** tab

#### Add Capabilities:

**a) Push Notifications:**
1. Click **+ Capability**
2. Search and add **Push Notifications**

**b) Background Modes:**
1. Click **+ Capability**
2. Search and add **Background Modes**
3. Check **✅ Audio, AirPlay, and Picture in Picture**

---

## Step 6: Configure Info.plist

### 6.1 Main App Info.plist

1. In Project Navigator, find **Info.plist** (or Info under CircuitTimer target)
2. Right-click → **Open As → Source Code**
3. Add the following keys inside the `<dict>` tag:

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

### 6.2 Widget Extension Info.plist

The widget extension's Info.plist should already be configured, but verify it contains:

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.widgetkit-extension</string>
</dict>
```

---

## Step 7: Add Audio Files (Optional - Can Skip for Now)

The app will use system sounds as fallback if audio files aren't present. To add custom beep sounds:

1. Create/generate three .wav files:
   - `work_start.wav` (0.3s, 800Hz beep)
   - `rest_start.wav` (0.3s, 400Hz beep)
   - `workout_complete.wav` (0.5s, three beeps)

2. In Project Navigator, right-click on **CircuitTimer** group
3. Select **New Group** → Name it `Resources`
4. Right-click on **Resources** → **New Group** → Name it `Sounds`
5. Right-click on **Sounds** → **Add Files to "CircuitTimer"...**
6. Select your .wav files
7. Ensure:
   - ✅ Copy items if needed
   - ✅ CircuitTimer target checked
   - ❌ Widget target NOT checked

---

## Step 8: Configure Build Settings

### 8.1 Set Deployment Target

1. Select **CircuitTimer** project
2. Select **CircuitTimer** target
3. Go to **General** tab
4. Under **Deployment Info**:
   - **Minimum Deployments**: **iOS 16.1**

5. Select **CircuitTimerLiveActivity** target
6. Repeat: **Minimum Deployments**: **iOS 16.1**

### 8.2 Verify Signing

1. For **CircuitTimer** target:
   - **Signing & Capabilities** tab
   - Ensure **Team** is selected
   - **Automatically manage signing** should be checked

2. For **CircuitTimerLiveActivity** target:
   - Same team as main app
   - Automatically manage signing

---

## Step 9: Build and Test

### 9.1 Build the Project

1. Select scheme: **CircuitTimer**
2. Select destination: **iPhone 15 Pro** (or any iOS 16.1+ simulator)
3. Press **⌘ + B** to build
4. Fix any build errors (see Troubleshooting below)

### 9.2 Run in Simulator

1. Press **⌘ + R** to run
2. App should launch in simulator
3. Test the setup flow:
   - Configure work time (30s)
   - Configure rest time (10s)
   - Set rounds (3)
   - Tap "Start"
4. Timer should start and show progress

### 9.3 Simulator Limitations

**The following CANNOT be tested in simulator:**
- ❌ Live Activities (won't show on Lock Screen)
- ❌ Dynamic Island (iPhone 14 Pro+ hardware only)
- ❌ Audio ducking (no real audio session management)
- ❌ Background timer accuracy (suspension behavior differs)

**You MUST test on a real device for these features!**

### 9.4 Run on Physical Device

1. Connect iPhone via USB
2. Trust computer on iPhone if prompted
3. In Xcode, select your iPhone as destination
4. Press **⌘ + R**
5. If prompted about Developer Mode:
   - On iPhone: Settings → Privacy & Security → Developer Mode → Enable
6. App will install and run on device

---

## Step 10: Test Live Activities on Device

1. Start a workout in the app
2. **Lock the iPhone** immediately
3. Live Activity should appear on Lock Screen showing:
   - Current state (WORK/REST)
   - Countdown timer
   - Round indicator
   - Pause/Resume button

4. **Test Dynamic Island** (iPhone 14 Pro+ only):
   - The "pill" at top shows compact timer
   - Long-press to see expanded view

5. **Test audio ducking**:
   - Start Spotify playing music
   - Start workout in CircuitTimer
   - Lock phone
   - Listen for beeps - music should lower during beeps

---

## Troubleshooting

### Build Error: "Cannot find 'CircuitTimerAttributes' in scope"

**Cause:** Widget extension can't see the attributes.

**Solution:**
1. Select `Services/LiveActivityManager.swift`
2. File Inspector → Target Membership
3. Check ✅ **Both** CircuitTimer and CircuitTimerLiveActivity

### Build Error: "Module 'ActivityKit' not found"

**Cause:** Widget extension not properly configured.

**Solution:**
1. Delete widget extension target
2. Re-create with "Include Live Activity" checked
3. Re-import files

### Runtime Error: "Live Activity not authorized"

**Cause:** User hasn't granted permission.

**Solution:**
- On iPhone: Settings → CircuitTimer → Allow Notifications → Enable
- Live Activities require notification permissions

### Audio Ducking Not Working

**Cause:** Background Modes not configured or audio session issue.

**Solution:**
1. Verify **Background Modes → Audio** is checked in Capabilities
2. Test with Spotify actively playing music
3. Check AudioManager logs in console

### Timer Desyncs After Backgrounding

**Cause:** `synchronizeState()` not being called.

**Solution:**
1. Verify TimerView has `@Environment(\.scenePhase)`
2. Verify `.onChange(of: scenePhase)` calls `synchronizeState()`
3. Check console logs when foregrounding app

### Live Activity Not Updating

**Cause:** Update calls failing or ContentState issues.

**Solution:**
1. Check console for LiveActivityManager errors
2. Verify `intervalEndDate` is being set correctly
3. Ensure `.timer` text style is used in widget (auto-updates)

---

## Project Structure After Setup

```
CircuitTimer.xcodeproj
├── CircuitTimer/                                # Main app target
│   ├── CircuitTimerApp.swift                    # ✅ Entry point
│   ├── Models/
│   │   ├── TimerConfiguration.swift             # ✅
│   │   ├── TimerState.swift                     # ✅
│   │   └── IntervalType.swift                   # ✅
│   ├── ViewModels/
│   │   └── TimerViewModel.swift                 # ✅ Orchestration
│   ├── Services/
│   │   ├── TimerEngine.swift                    # ✅ Date-based logic
│   │   ├── AudioManager.swift                   # ✅ Audio ducking
│   │   └── LiveActivityManager.swift            # ✅🔗 SHARED with widget
│   ├── Views/
│   │   ├── ContentView.swift                    # ✅
│   │   ├── SetupView.swift                      # ✅
│   │   ├── TimerView.swift                      # ✅
│   │   └── Components/
│   │       ├── CircularProgressView.swift       # ✅
│   │       ├── TimeDisplayView.swift            # ✅
│   │       └── ControlButtonsView.swift         # ✅
│   ├── Utilities/
│   │   ├── TimeFormatter.swift                  # ✅
│   │   └── Constants.swift                      # ✅
│   ├── Resources/
│   │   └── Sounds/
│   │       ├── work_start.wav                   # ⚪ Optional
│   │       ├── rest_start.wav                   # ⚪ Optional
│   │       └── workout_complete.wav             # ⚪ Optional
│   └── Info.plist                               # ⚙️ Configured
│
└── CircuitTimerLiveActivity/                    # Widget extension target
    ├── CircuitTimerLiveActivityBundle.swift     # ✅
    ├── CircuitTimerLiveActivity.swift           # ✅ Widget UI
    ├── PauseResumeIntent.swift                  # ✅ AppIntent
    └── Info.plist                               # ⚙️ Configured

Legend:
✅ File created and imported
🔗 Shared between targets
⚪ Optional
⚙️ Configured with keys
```

---

## Next Steps After Setup

1. **Verify build succeeds** with no errors
2. **Test in simulator** to verify UI and basic logic
3. **Deploy to device** for Live Activities testing
4. **Test audio ducking** with Spotify/YouTube
5. **Test background accuracy** by locking phone for 2+ minutes
6. **Test Dynamic Island** (iPhone 14 Pro+ only)
7. **Run unit tests** (optional - create test target)
8. **Profile with Instruments** for memory leaks
9. **Add app icon** (Assets.xcassets)
10. **Prepare for App Store** submission

---

## Device Testing Checklist

When you test on a real device, verify:

- [ ] App launches successfully
- [ ] Setup screen allows configuration
- [ ] Timer starts and counts down
- [ ] Work → Rest transitions play beep
- [ ] Audio ducking lowers Spotify/YouTube volume
- [ ] Live Activity appears on Lock Screen
- [ ] Live Activity shows correct time (countdown)
- [ ] Live Activity shows correct round (X/Y)
- [ ] Pause button on Live Activity works
- [ ] Resume button on Live Activity works
- [ ] Dynamic Island shows compact view (iPhone 14 Pro+)
- [ ] Dynamic Island expands correctly (iPhone 14 Pro+)
- [ ] Timer continues accurately after 2+ minutes backgrounded
- [ ] State synchronizes when app foregrounds
- [ ] Workout completes and plays completion beep
- [ ] Live Activity dismisses after completion
- [ ] Reset button returns to setup screen

---

## Additional Resources

### Apple Documentation:
- [ActivityKit Framework](https://developer.apple.com/documentation/activitykit)
- [Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- [Dynamic Island](https://developer.apple.com/documentation/activitykit/displaying-live-data-on-the-lock-screen-with-live-activities)
- [AVAudioSession](https://developer.apple.com/documentation/avfaudio/avaudiosession)

### Useful Commands:
```bash
# Clean build folder (if build issues)
# In Xcode: Product → Clean Build Folder (⇧⌘K)

# Reset simulator (if state issues)
# Device → Erase All Content and Settings

# View device logs
# Window → Devices and Simulators → Select device → Open Console
```

---

## Summary

You've now:
- ✅ Created Xcode project with Widget Extension
- ✅ Imported all Swift code files
- ✅ Configured capabilities (Push Notifications, Background Modes)
- ✅ Set up Info.plist for Live Activities
- ✅ Shared LiveActivityManager between targets
- ✅ Ready to build and test!

**Next:** Build the project (⌘+B) and deploy to a real device to test Live Activities! 🎉

---

For questions or issues, refer to the implementation plan at:
`/home/jwo_25471/.claude/plans/clever-sprouting-valiant.md`
