import * as getters from 'ee/security_dashboard/store/modules/vulnerabilities/getters';

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
