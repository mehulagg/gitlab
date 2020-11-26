export const EPIC_DETAILS_CELL_WIDTH = 150;

export const EPIC_ITEM_HEIGHT = 50;

export const TIMELINE_CELL_MIN_WIDTH = 180;

export const SCROLL_BAR_SIZE = 16;

export const EPIC_HIGHLIGHT_REMOVE_AFTER = 3000;

export const DAYS_IN_WEEK = 7;

export const PERCENTAGE = 100;

export const SMALL_TIMELINE_BAR = 40;

export const PRESET_TYPES = {
  QUARTERS: 'QUARTERS',
  MONTHS: 'MONTHS',
  WEEKS: 'WEEKS',
};

export const EPICS_STATES = {
  ALL: 'all',
  OPENED: 'opened',
  CLOSED: 'closed',
};

export const EXTEND_AS = {
  PREPEND: 'prepend',
  APPEND: 'append',
};

export const PRESET_DEFAULTS = {
  QUARTERS: {
    TIMEFRAME_LENGTH: 21,
  },
  MONTHS: {
    TIMEFRAME_LENGTH: 8,
  },
  WEEKS: {
    TIMEFRAME_LENGTH: 7,
  },
};

export const PAST_DATE = new Date(new Date().getFullYear() - 100, 0, 1);

export const FUTURE_DATE = new Date(new Date().getFullYear() + 100, 0, 1);

export const EPIC_LEVEL_MARGIN = {
  1: 'ml-4',
  2: 'ml-6',
  3: 'ml-8',
  4: 'ml-10',
};

export const EPICS_LIMIT_DISMISSED_COOKIE_NAME = 'epics_limit_warning_dismissed';

export const EPICS_LIMIT_DISMISSED_COOKIE_TIMEOUT = 365;
