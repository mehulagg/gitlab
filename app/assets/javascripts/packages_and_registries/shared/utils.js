import { queryToObject } from '~/lib/utils/url_utility';

export const getQueryParams = (query) => queryToObject(query, { gatherArrays: true });

export const keyValueToFilterToken = (type, data) => ({ type, value: { data } });

export const searchArrayToFilterTokens = (search) =>
  search.map((s) => keyValueToFilterToken('filtered-search-term', s));
