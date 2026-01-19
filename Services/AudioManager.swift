//
//  AudioManager.swift
//  CircuitTimer
//
//  Manages audio playback with ducking for workout beeps
//

import AVFoundation
import Combine

/// Manages audio session and beep playback with ducking
///
/// This class handles AVAudioSession configuration with the `.duckOthers` option
/// to temporarily lower other apps' volume (Spotify, YouTube, etc.) during beeps.
class AudioManager: ObservableObject {
    // MARK: - Properties

    /// Audio player instance
    private var audioPlayer: AVAudioPlayer?

    /// Whether sounds are enabled
    @Published var soundsEnabled: Bool = true

    // MARK: - Beep Types

    /// Type of beep sound to play
    enum BeepType: String {
        case workStart = "work_start"
        case restStart = "rest_start"
        case workoutComplete = "workout_complete"

        /// System sound ID for fallback (if audio files aren't available)
        var systemSoundID: SystemSoundID {
            switch self {
            case .workStart:
                return 1054 // High beep
            case .restStart:
                return 1057 // Low beep
            case .workoutComplete:
                return 1025 // Three beeps
            }
        }
    }

    // MARK: - Public Methods

    /// Play a beep sound with audio ducking
    /// - Parameter type: Type of beep to play
    func playBeep(_ type: BeepType) {
        guard soundsEnabled else { return }

        // Step 1: Deactivate any previous audio session
        deactivateAudioSession()

        // Step 2: Configure audio session with ducking
        configureAudioSession()

        // Step 3: Play the beep
        playSound(type)

        // Step 4: Deactivate after a short delay to restore other apps' volume
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.deactivateAudioSession()
        }
    }

    // MARK: - Private Methods

    /// Configure audio session for playback with ducking
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()

            // CRITICAL: Use .playback (not .ambient) with .duckOthers
            // This lowers other apps' volume temporarily during our beeps
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.duckOthers]
            )

            try session.setActive(true)
        } catch {
            print("AudioManager: Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    /// Deactivate audio session to restore other apps' volume
    private func deactivateAudioSession() {
        do {
            // Use .notifyOthersOnDeactivation to tell other apps to restore their volume
            try AVAudioSession.sharedInstance().setActive(
                false,
                options: .notifyOthersOnDeactivation
            )
        } catch {
            print("AudioManager: Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }

    /// Play the actual sound file
    /// - Parameter type: Type of beep to play
    private func playSound(_ type: BeepType) {
        // Try to load audio file from bundle
        if let url = Bundle.main.url(forResource: type.rawValue, withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                return
            } catch {
                print("AudioManager: Failed to play audio file \(type.rawValue).wav: \(error.localizedDescription)")
            }
        }

        // Fallback to system sound if audio file not available
        print("AudioManager: Audio file not found, using system sound")
        playSystemSound(type.systemSoundID)
    }

    /// Play a system sound as fallback
    /// - Parameter soundID: System sound ID
    private func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }

    /// Toggle sounds on/off
    func toggleSounds() {
        soundsEnabled.toggle()
    }
}

// MARK: - Audio File Generation Instructions
/*
 Audio files should be placed in Resources/Sounds/ folder:

 1. work_start.wav (0.3-0.5 seconds)
    - High pitch beep (800Hz)
    - Single beep
    - Volume: 70%

 2. rest_start.wav (0.3-0.5 seconds)
    - Lower pitch beep (400Hz)
    - Single beep
    - Volume: 70%

 3. workout_complete.wav (0.5-1.0 seconds)
    - Three short beeps sequence (800Hz)
    - Celebratory tone
    - Volume: 80%

 You can generate these using:
 - Audacity (free, cross-platform)
 - GarageBand (macOS)
 - Online tone generators
 - Or use system sounds as fallback (already implemented)

 Format requirements:
 - Format: WAV (uncompressed)
 - Sample rate: 44.1kHz or 48kHz
 - Bit depth: 16-bit
 - Channels: Mono or Stereo
 */
