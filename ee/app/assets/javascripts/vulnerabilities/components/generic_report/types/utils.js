import { REPORT_TYPES } from './constants';

/**
 * Check if a given type is supported (i.e, is mapped to a component and can be rendered)
 *
 * @param string type
 * @returns boolean
 */
export const isValidReportType = (type) => REPORT_TYPES.includes(type);
