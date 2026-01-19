import { useState, useEffect, useRef, useCallback } from 'react';
import {
  createTargetEndTime,
  calculateTimeRemaining,
  calculateProgress,
  hasIntervalEnded,
  calculatePausedRemaining,
  createResumeEndTime
} from '../utils/timerEngine';

/**
 * Custom hook for managing CrossFit interval timer
 * Uses date-based timing to prevent drift
 *
 * @param {Object} config - Timer configuration
 * @param {number} config.workDuration - Work interval duration in seconds
 * @param {number} config.restDuration - Rest interval duration in seconds
 * @param {number} config.totalRounds - Total number of rounds
 * @param {Function} onStateChange - Callback for state changes (for audio feedback)
 * @returns {Object} Timer state and control functions
 */
export const useTimer = (config, onStateChange) => {
  const [state, setState] = useState('idle'); // 'idle', 'work', 'rest', 'restBetweenSets', 'paused', 'finished'
  const [timeRemaining, setTimeRemaining] = useState(0);
  const [currentRound, setCurrentRound] = useState(1);
  const [currentSet, setCurrentSet] = useState(1);
  const [progress, setProgress] = useState(0);

  const intervalIdRef = useRef(null);
  const targetEndTimeRef = useRef(null);
  const pausedRemainingRef = useRef(null);
  const previousStateRef = useRef(null);
  const currentDurationRef = useRef(0);

  /**
   * Advance to the next interval (work -> rest -> work, etc.)
   */
  const advanceToNextInterval = useCallback(() => {
    if (state === 'work') {
      // Transition to rest
      const restDuration = config.restDuration;
      if (restDuration > 0) {
        setState('rest');
        targetEndTimeRef.current = createTargetEndTime(restDuration);
        currentDurationRef.current = restDuration;
      } else {
        // No rest period, go to next round or check for set completion
        if (currentRound < config.totalRounds) {
          setCurrentRound(prev => prev + 1);
          setState('work');
          targetEndTimeRef.current = createTargetEndTime(config.workDuration);
          currentDurationRef.current = config.workDuration;
        } else {
          // Last round of set completed, check for next set
          if (currentSet < config.totalSets) {
            const restBetweenSets = config.restBetweenSets || 0;
            if (restBetweenSets > 0) {
              setState('restBetweenSets');
              targetEndTimeRef.current = createTargetEndTime(restBetweenSets);
              currentDurationRef.current = restBetweenSets;
            } else {
              // No rest between sets, start next set immediately
              setCurrentSet(prev => prev + 1);
              setCurrentRound(1);
              setState('work');
              targetEndTimeRef.current = createTargetEndTime(config.workDuration);
              currentDurationRef.current = config.workDuration;
            }
          } else {
            // All sets completed
            setState('finished');
            setTimeRemaining(0);
            setProgress(1);
          }
        }
      }
    } else if (state === 'rest') {
      // Transition to next work interval within set or to next set
      if (currentRound < config.totalRounds) {
        // More rounds in this set
        setCurrentRound(prev => prev + 1);
        setState('work');
        targetEndTimeRef.current = createTargetEndTime(config.workDuration);
        currentDurationRef.current = config.workDuration;
      } else {
        // Last round of set completed, check for next set
        if (currentSet < config.totalSets) {
          const restBetweenSets = config.restBetweenSets || 0;
          if (restBetweenSets > 0) {
            setState('restBetweenSets');
            targetEndTimeRef.current = createTargetEndTime(restBetweenSets);
            currentDurationRef.current = restBetweenSets;
          } else {
            // No rest between sets, start next set immediately
            setCurrentSet(prev => prev + 1);
            setCurrentRound(1);
            setState('work');
            targetEndTimeRef.current = createTargetEndTime(config.workDuration);
            currentDurationRef.current = config.workDuration;
          }
        } else {
          // All sets completed
          setState('finished');
          setTimeRemaining(0);
          setProgress(1);
        }
      }
    } else if (state === 'restBetweenSets') {
      // Transition to first round of next set
      setCurrentSet(prev => prev + 1);
      setCurrentRound(1);
      setState('work');
      targetEndTimeRef.current = createTargetEndTime(config.workDuration);
      currentDurationRef.current = config.workDuration;
    }
  }, [state, currentRound, currentSet, config]);

  /**
   * Update timer display
   */
  useEffect(() => {
    if ((state === 'work' || state === 'rest' || state === 'restBetweenSets') && targetEndTimeRef.current) {
      intervalIdRef.current = setInterval(() => {
        const remaining = calculateTimeRemaining(targetEndTimeRef.current);
        const prog = calculateProgress(targetEndTimeRef.current, currentDurationRef.current);

        setTimeRemaining(remaining);
        setProgress(prog);

        if (hasIntervalEnded(targetEndTimeRef.current)) {
          clearInterval(intervalIdRef.current);
          advanceToNextInterval();
        }
      }, 100); // Update every 100ms for smooth animation

      return () => {
        if (intervalIdRef.current) {
          clearInterval(intervalIdRef.current);
        }
      };
    }
  }, [state, advanceToNextInterval]);

  /**
   * Notify state changes for audio feedback
   */
  useEffect(() => {
    if (onStateChange) {
      onStateChange(state);
    }
  }, [state, onStateChange]);

  /**
   * Start the timer from idle
   */
  const start = useCallback(() => {
    if (state === 'idle') {
      setState('work');
      setCurrentRound(1);
      setCurrentSet(1);
      targetEndTimeRef.current = createTargetEndTime(config.workDuration);
      currentDurationRef.current = config.workDuration;
      setTimeRemaining(config.workDuration);
      setProgress(0);
    }
  }, [state, config.workDuration]);

  /**
   * Pause the timer
   */
  const pause = useCallback(() => {
    if (state === 'work' || state === 'rest' || state === 'restBetweenSets') {
      if (intervalIdRef.current) {
        clearInterval(intervalIdRef.current);
      }
      pausedRemainingRef.current = calculatePausedRemaining(targetEndTimeRef.current);
      previousStateRef.current = state; // Store the state before pausing
      setState('paused');
    }
  }, [state]);

  /**
   * Resume the timer from paused state
   */
  const resume = useCallback(() => {
    if (state === 'paused' && pausedRemainingRef.current !== null && previousStateRef.current) {
      // Resume to the state before pausing
      const resumeState = previousStateRef.current;

      setState(resumeState);
      targetEndTimeRef.current = createResumeEndTime(pausedRemainingRef.current);
      currentDurationRef.current = resumeState === 'work' ? config.workDuration : config.restDuration;
    }
  }, [state, config]);

  /**
   * Reset timer to idle state
   */
  const reset = useCallback(() => {
    if (intervalIdRef.current) {
      clearInterval(intervalIdRef.current);
    }
    setState('idle');
    setTimeRemaining(0);
    setCurrentRound(1);
    setCurrentSet(1);
    setProgress(0);
    targetEndTimeRef.current = null;
    pausedRemainingRef.current = null;
    previousStateRef.current = null;
    currentDurationRef.current = 0;
  }, []);

  return {
    state,
    timeRemaining,
    currentRound,
    currentSet,
    progress,
    totalRounds: config.totalRounds,
    totalSets: config.totalSets,
    start,
    pause,
    resume,
    reset
  };
};
