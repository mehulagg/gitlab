export * from '~/vue_shared/security_reports/store/constants';

/**
 * Vuex module names corresponding to security scan types. These are similar to
 * the snake_case report types from the backend, but should not be considered
 * to be equivalent.
 *
 * These aren't technically Vuex modules yet, but they do correspond to
 * namespaces in the store state, as if they were modules.
 */
export const MODULE_CONTAINER_SCANNING = 'containerScanning';
export const MODULE_API_FUZZING = 'apiFuzzing';
export const MODULE_COVERAGE_FUZZING = 'coverageFuzzing';
export const MODULE_DAST = 'dast';
export const MODULE_DEPENDENCY_SCANNING = 'dependencyScanning';

/**
 * Tracks snowplow event when user views report details
 */
export const trackMrSecurityReportDetails = {
  category: 'Vulnerability_Management',
  action: 'mr_report_inline_details',
};
