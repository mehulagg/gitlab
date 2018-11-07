import { sum } from '~/lib/utils/number_utils';

export const vulnerabilitiesCountBySeverity = state => severity =>
  Object.values(state.vulnerabilitiesCount)
    .map(count => count[severity])
    .reduce(sum, 0);
export const vulnerabilitiesCountByReportType = state => type => {
  const counts = state.vulnerabilitiesCount[type];
  return counts ? Object.values(counts).reduce(sum, 0) : 0;
};
export const dashboardError = state =>
  state.errorLoadingVulnerabilities && state.errorLoadingVulnerabilitiesCount;
export const dashboardListError = state =>
  state.errorLoadingVulnerabilities && !state.errorLoadingVulnerabilitiesCount;
export const dashboardCountError = state =>
  !state.errorLoadingVulnerabilities && state.errorLoadingVulnerabilitiesCount;

export default () => {};
