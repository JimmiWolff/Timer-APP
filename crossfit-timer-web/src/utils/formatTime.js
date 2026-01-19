/**
 * Format seconds into MM:SS format
 * @param {number} seconds - Total seconds (can be decimal)
 * @returns {string} Formatted time string (MM:SS)
 */
export const formatTime = (seconds) => {
  const totalSeconds = Math.ceil(seconds);
  const minutes = Math.floor(totalSeconds / 60);
  const remainingSeconds = totalSeconds % 60;

  return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
};

/**
 * Convert minutes and seconds to total seconds
 * @param {number} minutes
 * @param {number} seconds
 * @returns {number} Total seconds
 */
export const toSeconds = (minutes, seconds) => {
  return minutes * 60 + seconds;
};

/**
 * Convert total seconds to minutes and seconds object
 * @param {number} totalSeconds
 * @returns {{minutes: number, seconds: number}}
 */
export const fromSeconds = (totalSeconds) => {
  return {
    minutes: Math.floor(totalSeconds / 60),
    seconds: totalSeconds % 60
  };
};
