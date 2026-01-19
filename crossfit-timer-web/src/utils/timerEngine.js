/**
 * Timer Engine - Date-based timer calculations to prevent drift
 * Matches the iOS TimerEngine.swift implementation pattern
 */

/**
 * Calculate time remaining until target end time
 * @param {number} targetEndTime - Target end timestamp (Date.now() format)
 * @returns {number} Seconds remaining (can be 0 if ended)
 */
export const calculateTimeRemaining = (targetEndTime) => {
  const now = Date.now();
  const remaining = Math.max(0, targetEndTime - now);
  return remaining / 1000; // Convert to seconds
};

/**
 * Calculate progress percentage for an interval
 * @param {number} targetEndTime - Target end timestamp
 * @param {number} duration - Total duration in seconds
 * @returns {number} Progress from 0 to 1
 */
export const calculateProgress = (targetEndTime, duration) => {
  const timeRemaining = calculateTimeRemaining(targetEndTime);
  const elapsed = duration - timeRemaining;
  return Math.min(1, Math.max(0, elapsed / duration));
};

/**
 * Check if interval has ended
 * @param {number} targetEndTime - Target end timestamp
 * @returns {boolean} True if interval has ended
 */
export const hasIntervalEnded = (targetEndTime) => {
  return Date.now() >= targetEndTime;
};

/**
 * Create a new target end time for an interval
 * @param {number} durationSeconds - Duration in seconds
 * @returns {number} Target end timestamp
 */
export const createTargetEndTime = (durationSeconds) => {
  return Date.now() + (durationSeconds * 1000);
};

/**
 * Calculate remaining time when paused
 * @param {number} targetEndTime - Original target end time
 * @returns {number} Seconds remaining at pause time
 */
export const calculatePausedRemaining = (targetEndTime) => {
  return calculateTimeRemaining(targetEndTime);
};

/**
 * Create new target end time when resuming from pause
 * @param {number} pausedRemaining - Seconds remaining when paused
 * @returns {number} New target end timestamp
 */
export const createResumeEndTime = (pausedRemaining) => {
  return createTargetEndTime(pausedRemaining);
};
