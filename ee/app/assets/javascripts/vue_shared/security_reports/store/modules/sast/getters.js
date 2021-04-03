import messages from '../../messages';
import { statusIcon, groupedReportText } from '../../utils';

export const groupedSastText = (state) =>
  groupedReportText(state, messages.SAST, messages.SAST_HAS_ERROR, messages.SAST_IS_LOADING);

export const sastStatusIcon = ({ isLoading, hasError, newIssues }) =>
  statusIcon(isLoading, hasError, newIssues.length);
