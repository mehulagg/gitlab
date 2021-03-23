import { REPORT_TYPES, REPORT_TYPE_LIST } from './constants';

/**
 * Check if a given type is supported (i.e, is mapped to a component and can be rendered)
 *
 * @param string type
 * @returns boolean
 */
export const isSupportedReportType = (type) => REPORT_TYPES.includes(type);

/**
 * Check if the given type is a list
 *
 * @param string type
 * @returns boolean
 */
export const isListType = (type) => type === REPORT_TYPE_LIST;
