import createState from 'ee/security_dashboard/store/modules/vulnerabilities/state';
import { DAYS } from 'ee/security_dashboard/store/modules/vulnerabilities/constants';
import * as getters from 'ee/security_dashboard/store/modules/vulnerabilities/getters';
import mockHistoryData from './data/mock_data_vulnerabilities_history.json';

describe('vulnerabilities module getters', () => {
  describe('dashboardError', () => {
    it('should return true when both error states exist', () => {
      const errorLoadingVulnerabilities = true;
      const errorLoadingVulnerabilitiesCount = true;
      const state = { errorLoadingVulnerabilities, errorLoadingVulnerabilitiesCount };
      const result = getters.dashboardError(state);

      expect(result).toBe(true);
    });
  });

  describe('dashboardCountError', () => {
    it('should return true if the count error exists', () => {
      const state = {
        errorLoadingVulnerabilitiesCount: true,
      };
      const result = getters.dashboardCountError(state);

      expect(result).toBe(true);
    });

    it('should return false if the list error exists as well', () => {
      const state = {
        errorLoadingVulnerabilities: true,
        errorLoadingVulnerabilitiesCount: true,
      };
      const result = getters.dashboardCountError(state);

      expect(result).toBe(false);
    });
  });

  describe('dashboardListError', () => {
    it('should return true when the list error exists', () => {
      const state = {
        errorLoadingVulnerabilities: true,
      };
      const result = getters.dashboardListError(state);

      expect(result).toBe(true);
    });

    it('should return false if the count error exists as well', () => {
      const state = {
        errorLoadingVulnerabilities: true,
        errorLoadingVulnerabilitiesCount: true,
      };
      const result = getters.dashboardListError(state);

      expect(result).toBe(false);
    });
  });

  describe('getFilteredVulnerabilitiesHistory', () => {
    let state;

    const mockedGetters = () => {
      const getVulnerabilityHistoryByName = name =>
        getters.getVulnerabilityHistoryByName(state)(name);
      return { getVulnerabilityHistoryByName };
    };

    beforeEach(() => {
      state = createState();
      state.vulnerabilitiesHistory = mockHistoryData;

      const mockDate = new Date(2019, 1, 2);
      const originalDate = Date;
      jest.spyOn(global, 'Date').mockImplementation(() => mockDate);
      global.Date.now = originalDate.now;
      global.Date.parse = originalDate.parse;
      global.Date.UTC = originalDate.UTC;
    });

    it('should filter the data to the last 30 days and days we have data for', () => {
      state.vulnerabilitiesHistoryDayRange = DAYS.THIRTY;
      const filteredResults = getters.getFilteredVulnerabilitiesHistory(state, mockedGetters())(
        'critical',
      );

      expect(filteredResults).toHaveLength(28);
    });

    it('should filter the data to the last 60 days and days we have data for', () => {
      state.vulnerabilitiesHistoryDayRange = DAYS.SIXTY;
      const filteredResults = getters.getFilteredVulnerabilitiesHistory(state, mockedGetters())(
        'critical',
      );

      expect(filteredResults).toHaveLength(58);
    });

    it('should filter the data to the last 90 days and days we have data for', () => {
      state.vulnerabilitiesHistoryDayRange = DAYS.NINETY;
      const filteredResults = getters.getFilteredVulnerabilitiesHistory(state, mockedGetters())(
        'critical',
      );

      expect(filteredResults).toHaveLength(88);
    });
  });

  describe('isSelectingVulnerabilities', () => {
    it('should return true if we have selected vulnerabilities', () => {
      const mockedGetters = { selectedVulnerabilitiesCount: 3 };
      const result = getters.isSelectingVulnerabilities({}, mockedGetters);

      expect(result).toBe(true);
    });

    it('should return false if no vulnerabilites are selected', () => {
      const mockedGetters = { selectedVulnerabilitiesCount: 0 };
      const result = getters.isSelectingVulnerabilities({}, mockedGetters);

      expect(result).toBe(false);
    });
  });

  describe('selectedVulnerabilitiesCount', () => {
    it('should return the amount of selected vulnerabilities', () => {
      const state = { selectedVulnerabilities: { 1: true, 2: true, 3: true } };
      const result = getters.selectedVulnerabilitiesCount(state);

      expect(result).toBe(3);
    });

    it('should return 0 when no vulnerabilities are selected', () => {
      const state = { selectedVulnerabilities: {} };
      const result = getters.selectedVulnerabilitiesCount(state);

      expect(result).toBe(0);
    });
  });

  describe('hasSelectedAllVulnerabilities', () => {
    it('should should return true when all the vulnerabilities are selected', () => {
      const state = { vulnerabilities: [1, 2, 3] };
      const mockedGetters = {
        isSelectingVulnerabilities: true,
        selectedVulnerabilitiesCount: state.vulnerabilities.length,
      };
      const result = getters.hasSelectedAllVulnerabilities(state, mockedGetters);

      expect(result).toBe(true);
    });

    it('should should return false when only not all the vulnerabilities are selected', () => {
      const state = { vulnerabilities: [1, 2, 3] };
      const mockedGetters = {
        isSelectingVulnerabilities: true,
        selectedVulnerabilitiesCount: state.vulnerabilities.length - 1,
      };
      const result = getters.hasSelectedAllVulnerabilities(state, mockedGetters);

      expect(result).toBe(false);
    });

    it('should should return false when not selecting vulnerabilities', () => {
      const state = { vulnerabilities: [] };
      const mockedGetters = {
        isSelectingVulnerabilities: false,
        selectedVulnerabilitiesCount: 0,
      };
      const result = getters.hasSelectedAllVulnerabilities(state, mockedGetters);

      expect(result).toBe(false);
    });
  });
});
