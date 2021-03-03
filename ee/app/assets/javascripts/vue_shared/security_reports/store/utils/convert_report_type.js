import { REPORT_TYPES } from 'ee/security_dashboard/store/constants';
import { humanize } from '~/lib/utils/text_utility';

/**
 * Takes the report type, that is not human-readable and converts it to be human-readable
 * @param {string} reportType that is not human-readable
 * @returns {string} a human-readable version of the report type
 */
const convertReportType = (reportType) => {
  if (!reportType) return '';
  const lowerCaseType = reportType.toLowerCase();
  return REPORT_TYPES[lowerCaseType] || humanize(lowerCaseType);
};

export default convertReportType;
