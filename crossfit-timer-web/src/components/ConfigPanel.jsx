import { useState, useEffect } from 'react';
import { toSeconds, fromSeconds } from '../utils/formatTime';
import './ConfigPanel.css';

/**
 * ConfigPanel Component
 * Configuration panel for work/rest durations and rounds
 *
 * @param {Object} props
 * @param {Object} props.config - Current timer configuration
 * @param {Function} props.onConfigChange - Callback when configuration changes
 * @param {boolean} props.disabled - Whether the panel should be disabled (during active workout)
 */
const ConfigPanel = ({ config, onConfigChange, disabled }) => {
  const [workMinutes, setWorkMinutes] = useState(0);
  const [workSeconds, setWorkSeconds] = useState(0);
  const [restMinutes, setRestMinutes] = useState(0);
  const [restSeconds, setRestSeconds] = useState(0);
  const [rounds, setRounds] = useState(8);
  const [sets, setSets] = useState(1);
  const [restBetweenSetsMinutes, setRestBetweenSetsMinutes] = useState(0);
  const [restBetweenSetsSeconds, setRestBetweenSetsSeconds] = useState(0);

  // Initialize from config
  useEffect(() => {
    const work = fromSeconds(config.workDuration);
    const rest = fromSeconds(config.restDuration);
    const restBetweenSets = fromSeconds(config.restBetweenSets || 0);
    setWorkMinutes(work.minutes);
    setWorkSeconds(work.seconds);
    setRestMinutes(rest.minutes);
    setRestSeconds(rest.seconds);
    setRounds(config.totalRounds);
    setSets(config.totalSets || 1);
    setRestBetweenSetsMinutes(restBetweenSets.minutes);
    setRestBetweenSetsSeconds(restBetweenSets.seconds);
  }, [config]);

  // Update config when values change
  useEffect(() => {
    const workDuration = toSeconds(workMinutes, workSeconds);
    const restDuration = toSeconds(restMinutes, restSeconds);
    const restBetweenSetsDuration = toSeconds(restBetweenSetsMinutes, restBetweenSetsSeconds);

    if (workDuration > 0) {
      onConfigChange({
        workDuration,
        restDuration,
        totalRounds: rounds,
        totalSets: sets,
        restBetweenSets: restBetweenSetsDuration
      });
    }
  }, [workMinutes, workSeconds, restMinutes, restSeconds, rounds, sets, restBetweenSetsMinutes, restBetweenSetsSeconds, onConfigChange]);

  const applyPreset = (preset) => {
    if (preset === 'tabata') {
      setWorkMinutes(0);
      setWorkSeconds(20);
      setRestMinutes(0);
      setRestSeconds(10);
      setRounds(8);
      setSets(1);
      setRestBetweenSetsMinutes(0);
      setRestBetweenSetsSeconds(0);
    } else if (preset === 'emom') {
      setWorkMinutes(1);
      setWorkSeconds(0);
      setRestMinutes(0);
      setRestSeconds(0);
      setRounds(10);
      setSets(1);
      setRestBetweenSetsMinutes(0);
      setRestBetweenSetsSeconds(0);
    } else if (preset === 'custom') {
      setWorkMinutes(2);
      setWorkSeconds(0);
      setRestMinutes(1);
      setRestSeconds(0);
      setRounds(5);
      setSets(3);
      setRestBetweenSetsMinutes(2);
      setRestBetweenSetsSeconds(0);
    }
  };

  return (
    <div className="config-panel glass-card">
      <h3 className="config-title">Timer Configuration</h3>
      <p className="config-subtitle">Choose a preset or customize your workout</p>

      <div className="config-presets">
        <button
          className="preset-btn"
          onClick={() => applyPreset('tabata')}
          disabled={disabled}
        >
          Tabata (20s/10s)
        </button>
        <button
          className="preset-btn"
          onClick={() => applyPreset('emom')}
          disabled={disabled}
        >
          EMOM (1min)
        </button>
        <button
          className="preset-btn"
          onClick={() => applyPreset('custom')}
          disabled={disabled}
        >
          Custom (2min/1min)
        </button>
      </div>

      <div className="config-section">
        <label className="config-label">Work Interval</label>
        <div className="time-inputs">
          <div className="input-group">
            <input
              type="number"
              min="0"
              max="59"
              value={workMinutes}
              onChange={(e) => setWorkMinutes(Math.max(0, Math.min(59, parseInt(e.target.value) || 0)))}
              disabled={disabled}
              className="time-input"
            />
            <span className="input-label">min</span>
          </div>
          <div className="input-group">
            <input
              type="number"
              min="0"
              max="59"
              value={workSeconds}
              onChange={(e) => setWorkSeconds(Math.max(0, Math.min(59, parseInt(e.target.value) || 0)))}
              disabled={disabled}
              className="time-input"
            />
            <span className="input-label">sec</span>
          </div>
        </div>
      </div>

      <div className="config-section">
        <label className="config-label">Rest Interval</label>
        <div className="time-inputs">
          <div className="input-group">
            <input
              type="number"
              min="0"
              max="59"
              value={restMinutes}
              onChange={(e) => setRestMinutes(Math.max(0, Math.min(59, parseInt(e.target.value) || 0)))}
              disabled={disabled}
              className="time-input"
            />
            <span className="input-label">min</span>
          </div>
          <div className="input-group">
            <input
              type="number"
              min="0"
              max="59"
              value={restSeconds}
              onChange={(e) => setRestSeconds(Math.max(0, Math.min(59, parseInt(e.target.value) || 0)))}
              disabled={disabled}
              className="time-input"
            />
            <span className="input-label">sec</span>
          </div>
        </div>
      </div>

      <div className="config-section">
        <label className="config-label">Rounds (per set)</label>
        <div className="input-group">
          <input
            type="number"
            min="1"
            max="99"
            value={rounds}
            onChange={(e) => setRounds(Math.max(1, Math.min(99, parseInt(e.target.value) || 1)))}
            disabled={disabled}
            className="rounds-input"
          />
        </div>
      </div>

      <div className="config-section">
        <label className="config-label">Sets</label>
        <div className="input-group">
          <input
            type="number"
            min="1"
            max="99"
            value={sets}
            onChange={(e) => setSets(Math.max(1, Math.min(99, parseInt(e.target.value) || 1)))}
            disabled={disabled}
            className="rounds-input"
          />
        </div>
      </div>

      {sets > 1 && (
        <div className="config-section">
          <label className="config-label">Rest Between Sets</label>
          <div className="time-inputs">
            <div className="input-group">
              <input
                type="number"
                min="0"
                max="59"
                value={restBetweenSetsMinutes}
                onChange={(e) => setRestBetweenSetsMinutes(Math.max(0, Math.min(59, parseInt(e.target.value) || 0)))}
                disabled={disabled}
                className="time-input"
              />
              <span className="input-label">min</span>
            </div>
            <div className="input-group">
              <input
                type="number"
                min="0"
                max="59"
                value={restBetweenSetsSeconds}
                onChange={(e) => setRestBetweenSetsSeconds(Math.max(0, Math.min(59, parseInt(e.target.value) || 0)))}
                disabled={disabled}
                className="time-input"
              />
              <span className="input-label">sec</span>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ConfigPanel;
