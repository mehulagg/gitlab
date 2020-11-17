import { LOADING_VULNERABILITIES_ERROR_CODES } from './constants';

export const dashboardError = state =>
  state.errorLoadingVulnerabilities && state.errorLoadingVulnerabilitiesCount;
export const dashboardListError = state =>
  state.errorLoadingVulnerabilities && !state.errorLoadingVulnerabilitiesCount;
export const dashboardCountError = state =>
  !state.errorLoadingVulnerabilities && state.errorLoadingVulnerabilitiesCount;

export const loadingVulnerabilitiesFailedWithRecognizedErrorCode = state =>
  state.errorLoadingVulnerabilities &&
  Object.values(LOADING_VULNERABILITIES_ERROR_CODES).includes(
    state.loadingVulnerabilitiesErrorCode,
  );

export const getVulnerabilityHistoryByName = state => name =>
  state.vulnerabilitiesHistory[name.toLowerCase()];

export const getFilteredVulnerabilitiesHistory = (state, getters) => name => {
  const history = getters.getVulnerabilityHistoryByName(name);
  const days = state.vulnerabilitiesHistoryDayRange;

  if (!history) {
    return [];
  }

  const data = Object.entries(history);
  const currentDate = new Date();
  const startDate = new Date();

  startDate.setDate(currentDate.getDate() - days);

  return data.filter(date => {
    const parsedDate = Date.parse(date[0]);
    return parsedDate > startDate;
  });
};

export const selectedVulnerabilitiesCount = state =>
  Object.keys(state.selectedVulnerabilities).length;

export const isSelectingVulnerabilities = (state, getters) =>
  getters.selectedVulnerabilitiesCount > 0;

export const hasSelectedAllVulnerabilities = (state, getters) =>
  getters.isSelectingVulnerabilities &&
  getters.selectedVulnerabilitiesCount === state.vulnerabilities.length;
