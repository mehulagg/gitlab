import { s__, sprintf } from '~/locale';
import { countVulnerabilities, groupedTextBuilder, statusIcon, groupedReportText } from './utils';
import { LOADING, ERROR, SUCCESS } from './constants';
import messages from './messages';

export const groupedContainerScanningText = ({ containerScanning }) =>
  groupedReportText(
    containerScanning,
    messages.CONTAINER_SCANNING,
    messages.CONTAINER_SCANNING_HAS_ERROR,
    messages.CONTAINER_SCANNING_IS_LOADING,
  );

export const groupedSecretScanningText = ({ secretScanning }) =>
  groupedReportText(
    secretScanning,
    messages.SECRET_SCANNING,
    messages.SECRET_SCANNING_HAS_ERROR,
    messages.SECRET_SCANNING_IS_LOADING,
  );

export const groupedDastText = ({ dast }) =>
  groupedReportText(dast, messages.DAST, messages.DAST_HAS_ERROR, messages.DAST_IS_LOADING);

export const groupedDependencyText = ({ dependencyScanning }) =>
  groupedReportText(
    dependencyScanning,
    messages.DEPENDENCY_SCANNING,
    messages.DEPENDENCY_SCANNING_HAS_ERROR,
    messages.DEPENDENCY_SCANNING_IS_LOADING,
  );

export const groupedCoverageFuzzingText = ({ coverageFuzzing }) =>
  groupedReportText(
    coverageFuzzing,
    messages.COVERAGE_FUZZING,
    messages.COVERAGE_FUZZING_HAS_ERROR,
    messages.COVERAGE_FUZZING_IS_LOADING,
  );

export const summaryCounts = ({
  containerScanning,
  dast,
  dependencyScanning,
  sast,
  secretScanning,
} = {}) => {
  const allNewVulns = [
    ...containerScanning.newIssues,
    ...dast.newIssues,
    ...dependencyScanning.newIssues,
    ...sast.newIssues,
    ...secretScanning.newIssues,
  ];

  return countVulnerabilities(allNewVulns);
};

export const groupedSummaryText = (state, getters) => {
  const reportType = s__('ciReport|Security scanning');
  let status = '';

  // All reports are loading
  if (getters.areAllReportsLoading) {
    return sprintf(messages.TRANSLATION_IS_LOADING, { reportType });
  }

  // All reports returned error
  if (getters.allReportsHaveError) {
    return s__('ciReport|Security scanning failed loading any results');
  }

  if (getters.areReportsLoading && getters.anyReportHasError) {
    status = s__('ciReport|(is loading, errors when loading results)');
  } else if (getters.areReportsLoading && !getters.anyReportHasError) {
    status = s__('ciReport|(is loading)');
  } else if (!getters.areReportsLoading && getters.anyReportHasError) {
    status = s__('ciReport|(errors when loading results)');
  }

  const { critical, high, other } = getters.summaryCounts;

  return groupedTextBuilder({ reportType, status, critical, high, other });
};

export const summaryStatus = (state, getters) => {
  if (getters.areReportsLoading) {
    return LOADING;
  }

  if (getters.anyReportHasError || getters.anyReportHasIssues) {
    return ERROR;
  }

  return SUCCESS;
};

export const containerScanningStatusIcon = ({ containerScanning }) =>
  statusIcon(
    containerScanning.isLoading,
    containerScanning.hasError,
    containerScanning.newIssues.length,
  );

export const dastStatusIcon = ({ dast }) =>
  statusIcon(dast.isLoading, dast.hasError, dast.newIssues.length);

export const dependencyScanningStatusIcon = ({ dependencyScanning }) =>
  statusIcon(
    dependencyScanning.isLoading,
    dependencyScanning.hasError,
    dependencyScanning.newIssues.length,
  );

export const secretScanningStatusIcon = ({ secretScanning }) =>
  statusIcon(secretScanning.isLoading, secretScanning.hasError, secretScanning.newIssues.length);

export const coverageFuzzingStatusIcon = ({ coverageFuzzing }) =>
  statusIcon(coverageFuzzing.isLoading, coverageFuzzing.hasError, coverageFuzzing.newIssues.length);

export const areReportsLoading = state =>
  state.sast.isLoading ||
  state.dast.isLoading ||
  state.containerScanning.isLoading ||
  state.dependencyScanning.isLoading ||
  state.secretScanning.isLoading;

export const areAllReportsLoading = state =>
  state.sast.isLoading &&
  state.dast.isLoading &&
  state.containerScanning.isLoading &&
  state.dependencyScanning.isLoading &&
  state.secretScanning.isLoading;

export const allReportsHaveError = state =>
  state.sast.hasError &&
  state.dast.hasError &&
  state.containerScanning.hasError &&
  state.dependencyScanning.hasError &&
  state.secretScanning.hasError;

export const anyReportHasError = state =>
  state.sast.hasError ||
  state.dast.hasError ||
  state.containerScanning.hasError ||
  state.dependencyScanning.hasError ||
  state.secretScanning.hasError;

export const noBaseInAllReports = state =>
  !state.sast.hasBaseReport &&
  !state.dast.hasBaseReport &&
  !state.containerScanning.hasBaseReport &&
  !state.dependencyScanning.hasBaseReport &&
  !state.secretScanning.hasBaseReport;

export const anyReportHasIssues = state =>
  state.sast.newIssues.length > 0 ||
  state.dast.newIssues.length > 0 ||
  state.containerScanning.newIssues.length > 0 ||
  state.dependencyScanning.newIssues.length > 0 ||
  state.secretScanning.newIssues.length > 0;

export const isBaseSecurityReportOutOfDate = state =>
  state.sast.baseReportOutofDate ||
  state.dast.baseReportOutofDate ||
  state.containerScanning.baseReportOutofDate ||
  state.dependencyScanning.baseReportOutofDate ||
  state.secretScanning.baseReportOutofDate;

export const canCreateIssue = state => Boolean(state.createVulnerabilityFeedbackIssuePath);

export const canCreateMergeRequest = state =>
  Boolean(state.createVulnerabilityFeedbackMergeRequestPath);

export const canDismissVulnerability = state =>
  Boolean(state.createVulnerabilityFeedbackDismissalPath);
