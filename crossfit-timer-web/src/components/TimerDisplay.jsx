import { formatTime } from '../utils/formatTime';
import './TimerDisplay.css';

/**
 * TimerDisplay Component
 * Shows circular progress ring with large time display in center
 *
 * @param {Object} props
 * @param {number} props.timeRemaining - Time remaining in seconds
 * @param {number} props.progress - Progress from 0 to 1
 * @param {string} props.state - Current timer state
 * @param {number} props.currentRound - Current round number
 * @param {number} props.currentSet - Current set number
 * @param {number} props.totalRounds - Total number of rounds
 * @param {number} props.totalSets - Total number of sets
 */
const TimerDisplay = ({ timeRemaining, progress, state, currentRound, currentSet, totalRounds, totalSets }) => {
  // SVG circle properties
  const size = 300;
  const strokeWidth = 12;
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;

  // Calculate stroke offset for progress (inverted so it counts down)
  const strokeDashoffset = circumference * (1 - progress);

  return (
    <div className="timer-display">
      <svg className="progress-ring" width={size} height={size}>
        {/* Background circle */}
        <circle
          className="progress-ring-bg"
          cx={size / 2}
          cy={size / 2}
          r={radius}
          strokeWidth={strokeWidth}
        />
        {/* Progress circle */}
        <circle
          className="progress-ring-progress"
          cx={size / 2}
          cy={size / 2}
          r={radius}
          strokeWidth={strokeWidth}
          strokeDasharray={circumference}
          strokeDashoffset={strokeDashoffset}
          transform={`rotate(-90 ${size / 2} ${size / 2})`}
        />
      </svg>

      {/* Time display in center */}
      <div className="timer-content">
        <div className="time-display">
          {formatTime(timeRemaining)}
        </div>
        {state !== 'idle' && state !== 'finished' && (
          <>
            {totalSets > 1 && (
              <div className="set-counter">
                Set {currentSet} / {totalSets}
              </div>
            )}
            {state !== 'restBetweenSets' && (
              <div className="round-counter">
                Round {currentRound} / {totalRounds}
              </div>
            )}
          </>
        )}
        {state === 'finished' && (
          <div className="round-counter">
            Workout Complete!
          </div>
        )}
      </div>
    </div>
  );
};

export default TimerDisplay;
