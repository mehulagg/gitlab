import * as types from './mutation_types';

export const updateIssueActionsMap = {
  sast: 'sast/updateVulnerability',
  dependency_scanning: 'updateDependencyScanningIssue',
  container_scanning: 'updateContainerScanningIssue',
  dast: 'updateDastIssue',
  secret_detection: 'secretDetection/updateVulnerability',
  coverage_fuzzing: 'updateCoverageFuzzingIssue',
};

export default function configureMediator(store) {
  store.subscribe(({ type, payload }) => {
    switch (type) {
      case types.RECEIVE_DISMISS_VULNERABILITY_SUCCESS:
        if (updateIssueActionsMap[payload.category]) {
          store.dispatch(updateIssueActionsMap[payload.category], payload);
        }
        break;
      default:
    }
  });
}
