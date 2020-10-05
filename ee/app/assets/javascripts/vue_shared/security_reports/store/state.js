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

  containerScanning: {
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
  dast: {
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
  coverageFuzzing: {
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
  dependencyScanning: {
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
  secretScanning: {
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
