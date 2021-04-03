import { flow } from 'lodash';
import { parseIntPagination, normalizeHeaders } from '~/lib/utils/common_utils';

/**
 * Takes an object containing pagination related data (eg.: page, nextPage, ...)
 * and returns a new object which has this data grouped in a 'pageInfo' property
 *
 * @param {{page: *, nextPage: *, total: *, totalPages: *}}
 * @returns {{pageInfo: {total: *, nextPage: *, totalPages: *, page: *}}}
 */
const groupPageInfo = ({ page, nextPage, total, totalPages }) => ({
  pageInfo: { page, nextPage, total, totalPages },
});

/**
 * Returns an XHR-response's headers property
 *
 * @param {{headers}} res
 * @returns {*}
 */
const getHeaders = (res) => res.headers;

/**
 * Takes an XHR-response object and returns an object containing pagination related
 * data
 *
 * @param {{headers}}
 * @returns {{pageInfo: {}}}
 */
const pageInfo = flow(getHeaders, normalizeHeaders, parseIntPagination, groupPageInfo);

/**
 * Takes an XHR-response object and adds pagination related data do it
 * (eg.: page, nextPage, total, totalPages)
 *
 * @param {Object} res
 * @return {Object}
 */
const addPageInfo = (res) => (res?.headers ? { ...res, ...pageInfo(res) } : res);

export default addPageInfo;
