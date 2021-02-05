import { setUrlParams } from '~/lib/utils/url_utility';
import { createAuditEventSearchQuery } from '../utils';

/**
 * Returns the CSV export href for given base path and search filters
 * @param {string} exportUrl
 * @returns {string}
 */
export const buildExportHref = (state) => (exportUrl) => {
  return setUrlParams(
    createAuditEventSearchQuery({
      filterValue: state.filterValue,
      startDate: state.startDate,
      endDate: state.endDate,
    }),
    exportUrl,
  );
};
