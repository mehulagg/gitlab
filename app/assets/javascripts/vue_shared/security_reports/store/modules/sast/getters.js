import { statusIcon, groupedReportText } from '../../utils';
import { SAST, SAST_HAS_ERROR, SAST_IS_LOADING } from './constants';

export const groupedSastText = state =>
  groupedReportText(state, SAST, SAST_HAS_ERROR, SAST_IS_LOADING);

export const sastStatusIcon = ({ isLoading, hasError, newIssues }) =>
  statusIcon(isLoading, hasError, newIssues.length);
