import { statusIcon, groupedReportText } from '../../utils';
import messages from '../../messages';

export const groupedApiFuzzingText = (state) =>
  groupedReportText(
    state,
    messages.API_FUZZING,
    messages.API_FUZZING_HAS_ERROR,
    messages.API_FUZZING_IS_LOADING,
  );

export const apiFuzzingStatusIcon = ({ isLoading, hasError, newIssues }) =>
  statusIcon(isLoading, hasError, newIssues.length);
