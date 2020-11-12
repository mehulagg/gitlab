import {
  MODULE_CONTAINER_SCANNING,
  MODULE_COVERAGE_FUZZING,
  MODULE_DAST,
  MODULE_DEPENDENCY_SCANNING,
  MODULE_SAST,
  MODULE_SECRET_DETECTION,
} from './constants';

export default () => ({
  blobPath: {
    head: null,
    base: null,
  },

  sourceBranch: null,
  canReadVulnerabilityFeedback: false,
  vulnerabilityFeedbackPath: null,
  vulnerabilityFeedbackHelpPath: null,
  createVulnerabilityFeedbackIssuePath: null,
  createVulnerabilityFeedbackMergeRequestPath: null,
  createVulnerabilityFeedbackDismissalPath: null,
  pipelineId: null,

  reportTypes: [
    MODULE_CONTAINER_SCANNING,
    MODULE_COVERAGE_FUZZING,
    MODULE_DAST,
    MODULE_DEPENDENCY_SCANNING,
    MODULE_SAST,
    MODULE_SECRET_DETECTION,
  ],

  [MODULE_CONTAINER_SCANNING]: {
    paths: {
      head: null,
      base: null,
      diffEndpoint: null,
    },

    isLoading: false,
    hasError: false,

    newIssues: [],
    resolvedIssues: [],
    baseReportOutofDate: false,
    hasBaseReport: false,
  },
  [MODULE_DAST]: {
    paths: {
      head: null,
      base: null,
      diffEndpoint: null,
    },

    isLoading: false,
    hasError: false,

    newIssues: [],
    resolvedIssues: [],
    baseReportOutofDate: false,
    hasBaseReport: false,
    scans: [],
  },
  [MODULE_COVERAGE_FUZZING]: {
    paths: {
      head: null,
      base: null,
      diffEndpoint: null,
    },

    isLoading: false,
    hasError: false,

    newIssues: [],
    resolvedIssues: [],
    allIssues: [],
    baseReportOutofDate: false,
    hasBaseReport: false,
  },
  [MODULE_DEPENDENCY_SCANNING]: {
    paths: {
      head: null,
      base: null,
      diffEndpoint: null,
    },

    isLoading: false,
    hasError: false,

    newIssues: [],
    resolvedIssues: [],
    allIssues: [],
    baseReportOutofDate: false,
    hasBaseReport: false,
  },

  modal: {
    title: null,

    learnMoreUrl: null,

    vulnerability: {
      isDismissed: false,
      hasIssue: false,
      hasMergeRequest: false,
    },

    isShowingDeleteButtons: false,
    isCommentingOnDismissal: false,
    error: null,
  },

  isCreatingIssue: false,
  isDismissingVulnerability: false,
  isCreatingMergeRequest: false,
});
