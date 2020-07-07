import { getJSONFixture } from 'helpers/fixtures';
import * as types from '~/pipelines/stores/test_reports/mutation_types';
import mutations from '~/pipelines/stores/test_reports/mutations';

describe('Mutations TestReports Store', () => {
  let mockState;

  const testReports = getJSONFixture('pipelines/test_report.json');

  const defaultState = {
    endpoint: '',
    testReports: {},
    selectedSuite: {},
    isLoading: false,
  };

  beforeEach(() => {
    mockState = defaultState;
  });

  describe('set reports', () => {
    it('should set testReports', () => {
      const expectedState = { ...mockState, testReports };
      mutations[types.SET_REPORTS](mockState, testReports);

      expect(mockState.testReports).toEqual(expectedState.testReports);
    });
  });

  describe('set selected suite', () => {
    it('should set selectedSuite', () => {
      const selectedSuite = testReports.test_suites[0];
      mutations[types.SET_SELECTED_SUITE](mockState, selectedSuite);

      expect(mockState.selectedSuite).toEqual(selectedSuite);
    });
  });

  describe('set summary', () => {
    it('should set summary', () => {
      const summary = { total_count: 1 };
      mutations[types.SET_SUMMARY](mockState, summary);

      expect(mockState.summary).toEqual(summary);
    });
  });

  describe('toggle loading', () => {
    it('should set to true', () => {
      const expectedState = { ...mockState, isLoading: true };
      mutations[types.TOGGLE_LOADING](mockState);

      expect(mockState.isLoading).toEqual(expectedState.isLoading);
    });

    it('should toggle back to false', () => {
      const expectedState = { ...mockState, isLoading: false };
      mockState.isLoading = true;

      mutations[types.TOGGLE_LOADING](mockState);

      expect(mockState.isLoading).toEqual(expectedState.isLoading);
    });
  });
});
