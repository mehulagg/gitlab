import { REPORT_TYPES, REPORT_TYPE_LIST } from './constants';

export const isSupportedReportType = (type) => REPORT_TYPES.includes(type);
export const isListType = (type) => type === REPORT_TYPE_LIST;
