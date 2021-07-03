import { masks } from 'dateformat';
import { DEFAULT_DEBOUNCE_AND_THROTTLE_MS } from '~/lib/utils/constants';

const { isoDate, mediumDate } = masks;

export const dateFormats = {
  isoDate,
  defaultDate: mediumDate,
  defaultDateTime: 'mmm d, yyyy h:MMtt',
};

export const scatterChartLineProps = {
  default: {
    type: 'line',
    showSymbol: false,
    // By default zlevel is 2 for all series types.
    // By increasing the zlevel to 3 we make sure that the trendline gets drawn in front of the dots in the chart.
    zlevel: 3,
  },
};

export const DATE_RANGE_LIMIT = 180;

export const OFFSET_DATE_BY_ONE = 1;

export const NO_DRAG_CLASS = 'no-drag';

export const DATA_REFETCH_DELAY = DEFAULT_DEBOUNCE_AND_THROTTLE_MS;
