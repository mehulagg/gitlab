import { getDateInPast } from '~/lib/utils/datetime_utility';

export const TOTAL_DATAPOINTS_TO_FETCH = 365;
export const TODAY = new Date();
export const START_DATE = getDateInPast(TODAY, TOTAL_DATAPOINTS_TO_FETCH);
