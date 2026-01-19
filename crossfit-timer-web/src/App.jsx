import { useState, useCallback, useRef } from 'react';
import { useTimer } from './hooks/useTimer';
import TimerDisplay from './components/TimerDisplay';
import StateIndicator from './components/StateIndicator';
import TimerControls from './components/TimerControls';
import ConfigPanel from './components/ConfigPanel';
import './App.css';

/**
 * Main App Component
 * The Wolff Timer - Interval Timer with glassmorphism design
 */
function App() {
  const [config, setConfig] = useState({
    workDuration: 20,  // 20 seconds (Tabata default)
    restDuration: 10,  // 10 seconds
    totalRounds: 8,
    totalSets: 1,      // Number of sets
    restBetweenSets: 0 // Rest between sets in seconds
  });

  const [currentScreen, setCurrentScreen] = useState('config'); // 'config' or 'timer'

  const audioContextRef = useRef(null);

  /**
   * Play audio beep using Web Audio API
   * @param {number} frequency - Frequency in Hz
   * @param {number} duration - Duration in milliseconds
   */
  const playBeep = useCallback((frequency, duration) => {
    try {
      if (!audioContextRef.current) {
        audioContextRef.current = new (window.AudioContext || window.webkitAudioContext)();
      }

      const ctx = audioContextRef.current;
      const oscillator = ctx.createOscillator();
      const gainNode = ctx.createGain();

      oscillator.connect(gainNode);
      gainNode.connect(ctx.destination);

      oscillator.frequency.value = frequency;
      oscillator.type = 'sine';

      gainNode.gain.setValueAtTime(0.3, ctx.currentTime);
      gainNode.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + duration / 1000);

      oscillator.start(ctx.currentTime);
      oscillator.stop(ctx.currentTime + duration / 1000);
    } catch (error) {
      console.error('Audio playback failed:', error);
    }
  }, []);

  /**
   * Handle timer state changes for audio feedback
   */
  const handleStateChange = useCallback((state) => {
    switch (state) {
      case 'work':
        playBeep(800, 200); // Work start: 800Hz, 200ms
        break;
      case 'rest':
        playBeep(600, 200); // Rest start: 600Hz, 200ms
        break;
      case 'restBetweenSets':
        playBeep(500, 300); // Rest between sets: 500Hz, 300ms (lower tone, longer)
        break;
      case 'finished':
        playBeep(1000, 500); // Finished: 1000Hz, 500ms
        break;
      default:
        break;
    }
  }, [playBeep]);

  const {
    state,
    timeRemaining,
    currentRound,
    currentSet,
    progress,
    totalRounds,
    totalSets,
    start,
    pause,
    resume,
    reset
  } = useTimer(config, handleStateChange);

  /**
   * Get background gradient based on timer state
   */
  const getBackgroundGradient = () => {
    switch (state) {
      case 'work':
        return 'var(--gradient-work)';
      case 'rest':
        return 'var(--gradient-rest)';
      case 'restBetweenSets':
        return 'var(--gradient-rest-between-sets)';
      case 'finished':
        return 'var(--gradient-finished)';
      default:
        return 'var(--gradient-idle)';
    }
  };

  const handleConfigChange = useCallback((newConfig) => {
    setConfig(newConfig);
  }, []);

  const handleStart = useCallback(() => {
    start();
    setCurrentScreen('timer');
  }, [start]);

  const handleReset = useCallback(() => {
    reset();
    setCurrentScreen('config');
  }, [reset]);

  const isTimerActive = state !== 'idle' && state !== 'finished';

  return (
    <div className="app" style={{ background: getBackgroundGradient() }}>
      <div className="app-container">
        <header className="app-header">
          <h1 className="app-title">The Wolff Timer</h1>
        </header>

        <main className="app-main">
          {currentScreen === 'config' ? (
            <>
              <ConfigPanel
                config={config}
                onConfigChange={handleConfigChange}
                disabled={false}
              />
              <TimerControls
                state="idle"
                onStart={handleStart}
                onPause={pause}
                onResume={resume}
                onReset={handleReset}
              />
            </>
          ) : (
            <>
              <StateIndicator state={state} />

              <TimerDisplay
                timeRemaining={timeRemaining}
                progress={progress}
                state={state}
                currentRound={currentRound}
                currentSet={currentSet}
                totalRounds={totalRounds}
                totalSets={totalSets}
              />

              <TimerControls
                state={state}
                onStart={handleStart}
                onPause={pause}
                onResume={resume}
                onReset={handleReset}
              />
            </>
          )}
        </main>

        <footer className="app-footer">
          <p>Built with React + Vite | Glassmorphism Design</p>
        </footer>
      </div>
    </div>
  );
}

export default App;
