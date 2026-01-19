import './TimerControls.css';

/**
 * TimerControls Component
 * Play/pause/resume/reset buttons with glassmorphic styling
 *
 * @param {Object} props
 * @param {string} props.state - Current timer state
 * @param {Function} props.onStart - Start timer callback
 * @param {Function} props.onPause - Pause timer callback
 * @param {Function} props.onResume - Resume timer callback
 * @param {Function} props.onReset - Reset timer callback
 */
const TimerControls = ({ state, onStart, onPause, onResume, onReset }) => {
  return (
    <div className="timer-controls">
      {state === 'idle' && (
        <button className="control-btn glass-card start-btn" onClick={onStart}>
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M8 5v14l11-7z" />
          </svg>
          <span>Start</span>
        </button>
      )}

      {(state === 'work' || state === 'rest') && (
        <button className="control-btn glass-card pause-btn" onClick={onPause}>
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M6 4h4v16H6V4zm8 0h4v16h-4V4z" />
          </svg>
          <span>Pause</span>
        </button>
      )}

      {state === 'paused' && (
        <button className="control-btn glass-card resume-btn" onClick={onResume}>
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M8 5v14l11-7z" />
          </svg>
          <span>Resume</span>
        </button>
      )}

      {(state !== 'idle' && state !== 'finished') && (
        <button className="control-btn glass-card reset-btn" onClick={onReset}>
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 5V1L7 6l5 5V7c3.31 0 6 2.69 6 6s-2.69 6-6 6-6-2.69-6-6H4c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8z" />
          </svg>
          <span>Reset</span>
        </button>
      )}

      {state === 'finished' && (
        <button className="control-btn glass-card start-btn" onClick={onReset}>
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 5V1L7 6l5 5V7c3.31 0 6 2.69 6 6s-2.69 6-6 6-6-2.69-6-6H4c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8z" />
          </svg>
          <span>New Workout</span>
        </button>
      )}
    </div>
  );
};

export default TimerControls;
