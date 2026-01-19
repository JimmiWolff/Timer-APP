import './StateIndicator.css';

/**
 * StateIndicator Component
 * Displays the current timer state with animated badge
 *
 * @param {Object} props
 * @param {string} props.state - Current timer state ('idle', 'work', 'rest', 'restBetweenSets', 'paused', 'finished')
 */
const StateIndicator = ({ state }) => {
  const getStateLabel = () => {
    switch (state) {
      case 'work':
        return 'WORK';
      case 'rest':
        return 'REST';
      case 'restBetweenSets':
        return 'REST BETWEEN SETS';
      case 'paused':
        return 'PAUSED';
      case 'finished':
        return 'COMPLETE';
      case 'idle':
      default:
        return 'READY';
    }
  };

  const shouldPulse = state === 'work' || state === 'rest' || state === 'restBetweenSets';

  return (
    <div className={`state-indicator ${shouldPulse ? 'pulse' : ''}`}>
      <div className="state-badge glass-card">
        <span className="state-label">{getStateLabel()}</span>
      </div>
    </div>
  );
};

export default StateIndicator;
