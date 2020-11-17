import projectSpecificScanners from './graphql/project_specific_scanners.query.graphql';
import groupSpecificScanners from './graphql/group_specific_scanners.query.graphql';
import instanceSpecificScanners from './graphql/instance_specific_scanners.query.graphql';

export const COLLAPSE_SECURITY_REPORTS_SUMMARY_LOCAL_STORAGE_KEY =
  'hide_pipelines_security_reports_summary_details';

export const scannerFilterResultsKeyMap = {
  instance: 'instanceSecurityDashboard',
  project: 'project',
  group: 'group',
};

export const dashboardTypeQuery = {
  project: projectSpecificScanners,
  group: groupSpecificScanners,
  instance: instanceSpecificScanners,
};

export default () => ({});
