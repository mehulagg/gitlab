/* eslint-disable import/export */
import { invert } from 'lodash';
import {
  reportTypeToSecurityReportTypeEnum as reportTypeToSecurityReportTypeEnumCE,
  REPORT_TYPE_API_FUZZING,
  REPORT_TYPE_COVERAGE_FUZZING,
} from '~/vue_shared/security_reports/constants';

export * from '~/vue_shared/security_reports/constants';

/**
 * SecurityReportTypeEnum values for use with GraphQL.
 *
 * These should correspond to the lowercase security scan report types.
 */
export const SECURITY_REPORT_TYPE_ENUM_API_FUZZING = 'API_FUZZING';
export const SECURITY_REPORT_TYPE_ENUM_COVERAGE_FUZZING = 'COVERAGE_FUZZING';

/* Override CE Definitions */

/**
 * A mapping from security scan report types to SecurityReportTypeEnum values.
 */
export const reportTypeToSecurityReportTypeEnum = {
  ...reportTypeToSecurityReportTypeEnumCE,
  [REPORT_TYPE_API_FUZZING]: SECURITY_REPORT_TYPE_ENUM_API_FUZZING,
  [REPORT_TYPE_COVERAGE_FUZZING]: SECURITY_REPORT_TYPE_ENUM_COVERAGE_FUZZING,
};

/**
 * A mapping from SecurityReportTypeEnum values to security scan report types.
 */
export const securityReportTypeEnumToReportType = invert(reportTypeToSecurityReportTypeEnum);
