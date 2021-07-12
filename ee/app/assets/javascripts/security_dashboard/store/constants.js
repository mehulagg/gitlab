import { s__ } from '~/locale';

export const VULNERABILITIES_PER_PAGE = 20;

export const SEVERITY_LEVELS = {
  critical: s__('severity|Critical'),
  high: s__('severity|High'),
  medium: s__('severity|Medium'),
  low: s__('severity|Low'),
  unknown: s__('severity|Unknown'),
  info: s__('severity|Info'),
};

export const REPORT_TYPES = {
  container_scanning: s__('ciReport|Container Scanning'),
  cluster_image_scanning: s__('ciReport|Cluster Image Scanning'),
  dast: s__('ciReport|DAST'),
  dependency_scanning: s__('ciReport|Dependency Scanning'),
  sast: s__('ciReport|SAST'),
  secret_detection: s__('ciReport|Secret Detection'),
  coverage_fuzzing: s__('ciReport|Coverage Fuzzing'),
  api_fuzzing: s__('ciReport|API Fuzzing'),
};

export const DASHBOARD_TYPES = {
  PROJECT: 'project',
  PIPELINE: 'pipeline',
  GROUP: 'group',
  INSTANCE: 'instance',
};

export const UNSCANNED_PROJECTS_DATE_RANGES = [
  { description: s__('UnscannedProjects|5 or more days'), fromDay: 5, toDay: 15 },
  { description: s__('UnscannedProjects|15 or more days'), fromDay: 15, toDay: 30 },
  { description: s__('UnscannedProjects|30 or more days'), fromDay: 30, toDay: 60 },
  { description: s__('UnscannedProjects|60 or more days'), fromDay: 60, toDay: Infinity },
];

export const PRIMARY_IDENTIFIER_TYPE = 'cve';

export const DAYS = { thirty: 30, sixty: 60, ninety: 90 };
