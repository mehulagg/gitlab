import { tableSortOrder } from 'ee/analytics/productivity_analytics/constants';
import * as getters from 'ee/analytics/productivity_analytics/store/modules/table/getters';
import createState from 'ee/analytics/productivity_analytics/store/modules/table/state';

describe('Productivity analytics table getters', () => {
  let state;

  const metricTypes = [
    { key: 'time_to_first_comment', label: 'Time from first commit until first comment' },
    { key: 'time_to_last_commit', label: 'Time from first comment to last commit' },
    { key: 'time_to_merge', label: 'Time from last commit to merge' },
  ];

  beforeEach(() => {
    state = createState();
  });

  describe('sortIcon', () => {
    it('returns the correct icon when sort order is asc', () => {
      state = {
        sortOrder: tableSortOrder.asc.value,
      };

      expect(getters.sortIcon(state)).toBe('sort-lowest');
    });

    it('returns the correct icon when sort order is desc', () => {
      state = {
        sortOrder: tableSortOrder.desc.value,
      };

      expect(getters.sortIcon(state)).toBe('sort-highest');
    });
  });

  describe('sortTooltipTitle', () => {
    it('returns the correct title when sort order is asc', () => {
      state = {
        sortOrder: tableSortOrder.asc.value,
      };

      expect(getters.sortTooltipTitle(state)).toBe('Ascending');
    });

    it('returns the correct title when sort order is desc', () => {
      state = {
        sortOrder: tableSortOrder.desc.value,
      };

      expect(getters.sortTooltipTitle(state)).toBe('Descending');
    });
  });

  describe('sortFieldDropdownLabel', () => {
    it('returns the correct label for the current sort field', () => {
      const rootState = {
        metricTypes,
      };

      state.sortField = 'time_to_last_commit';

      expect(getters.sortFieldDropdownLabel(state, null, rootState)).toBe(
        'Time from first comment to last commit',
      );
    });
  });

  describe('tableSortOptions', () => {
    it('returns the metricTypes from the timeBasedHistogram and adds "Days to merge"', () => {
      const rootGetters = {
        getMetricTypes: () => metricTypes,
      };

      const expected = [{ key: 'days_to_merge', label: 'Days to merge' }, ...metricTypes];

      expect(getters.tableSortOptions(null, null, null, rootGetters)).toEqual(expected);
    });
  });
});
