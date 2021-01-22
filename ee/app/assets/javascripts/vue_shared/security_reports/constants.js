/* eslint-disable import/export */
import { invert } from 'lodash';
import { reportTypeToSecurityReportTypeEnum as reportTypeToSecurityReportTypeEnumCE } from '~/vue_shared/security_reports/constants';

export * from '~/vue_shared/security_reports/constants';

/**
 * Security scan report types, as provided by the backend.
 */
export const REPORT_TYPE_API_FUZZING = 'api_fuzzing';

/**
 * SecurityReportTypeEnum values for use with GraphQL.
 *
 * These should correspond to the lowercase security scan report types.
 */
export const SECURITY_REPORT_TYPE_ENUM_API_FUZZING = 'API_FUZZING';

/* Override CE Definitions */

/**
 * A mapping from security scan report types to SecurityReportTypeEnum values.
 */
export const reportTypeToSecurityReportTypeEnum = {
  ...reportTypeToSecurityReportTypeEnumCE,
  [REPORT_TYPE_API_FUZZING]: SECURITY_REPORT_TYPE_ENUM_API_FUZZING,
};

/**
 * A mapping from SecurityReportTypeEnum values to security scan report types.
 */
export const securityReportTypeEnumToReportType = invert(reportTypeToSecurityReportTypeEnum);
