import messages from '../../messages';
import { statusIcon, groupedReportText } from '../../utils';

export const groupedSecretDetectionText = (state) =>
  groupedReportText(
    state,
    messages.SECRET_SCANNING,
    messages.SECRET_SCANNING_HAS_ERROR,
    messages.SECRET_SCANNING_IS_LOADING,
  );

export const secretDetectionStatusIcon = ({ isLoading, hasError, newIssues }) =>
  statusIcon(isLoading, hasError, newIssues.length);
