export const DAYS_IN_WEEK = 7;

export const PRESET_TYPES = {
  WEEKS: 'WEEKS',
};

export const PRESET_DEFAULTS = {
  WEEKS: {
    TIMEFRAME_LENGTH: 2,
  },
};

export const PAST_DATE = new Date(new Date().getFullYear() - 100, 0, 1);

export const FUTURE_DATE = new Date(new Date().getFullYear() + 100, 0, 1);
