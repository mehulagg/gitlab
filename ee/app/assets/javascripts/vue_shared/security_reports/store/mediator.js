import { MODULE_API_FUZZING, MODULE_SAST, MODULE_SECRET_DETECTION } from './constants';
import * as types from './mutation_types';

export const updateIssueActionsMap = {
  sast: `${MODULE_SAST}/updateVulnerability`,
  dependency_scanning: 'updateDependencyScanningIssue',
  container_scanning: 'updateContainerScanningIssue',
  dast: 'updateDastIssue',
  secret_detection: `${MODULE_SECRET_DETECTION}/updateVulnerability`,
  coverage_fuzzing: 'updateCoverageFuzzingIssue',
  api_fuzzing: `${MODULE_API_FUZZING}/updateVulnerability`,
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
