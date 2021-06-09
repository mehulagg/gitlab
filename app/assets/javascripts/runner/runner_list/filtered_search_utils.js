import { queryToObject, setUrlParams } from '~/lib/utils/url_utility';
import {
  filterToQueryObject,
  processFilters,
  urlQueryToFilter,
  prepareTokens,
} from '~/vue_shared/components/filtered_search_bar/filtered_search_utils';
import {
  PARAM_KEY_STATUS,
  PARAM_KEY_RUNNER_TYPE,
  PARAM_KEY_SORT,
  PARAM_KEY_PAGE,
  PARAM_KEY_AFTER,
  PARAM_KEY_BEFORE,
  DEFAULT_SORT,
  RUNNER_PAGE_SIZE,
} from '../constants';

const getPaginationFromParams = (params) => {
  const page = parseInt(params[PARAM_KEY_PAGE], 10);
  const after = params[PARAM_KEY_AFTER];
  const before = params[PARAM_KEY_BEFORE];

  if (page && (before || after)) {
    return {
      page,
      before,
      after,
    };
  }
  return {
    page: 1,
  };
};

export const fromUrlQueryToSearch = (query = window.location.search) => {
  const params = queryToObject(query, { gatherArrays: true });
  const filterParamKeys = [PARAM_KEY_STATUS, PARAM_KEY_RUNNER_TYPE];

  return {
    filters: prepareTokens(urlQueryToFilter(query, filterParamKeys)),
    sort: params[PARAM_KEY_SORT] || DEFAULT_SORT,
    pagination: getPaginationFromParams(params),
  };
};

export const fromSearchToUrl = (
  { filters = [], sort = null, pagination = {} },
  url = window.location.href,
) => {
  const queryObj = filterToQueryObject(processFilters(filters));

  const urlParams = {
    [PARAM_KEY_STATUS]: queryObj[PARAM_KEY_STATUS] || [],
    [PARAM_KEY_RUNNER_TYPE]: queryObj[PARAM_KEY_RUNNER_TYPE] || [],
  };

  if (sort && sort !== DEFAULT_SORT) {
    urlParams[PARAM_KEY_SORT] = sort;
  }

  // Remove pagination params for first page
  if (pagination?.page === 1) {
    urlParams[PARAM_KEY_PAGE] = null;
    urlParams[PARAM_KEY_BEFORE] = null;
    urlParams[PARAM_KEY_AFTER] = null;
  } else {
    urlParams[PARAM_KEY_PAGE] = pagination.page;
    urlParams[PARAM_KEY_BEFORE] = pagination.before;
    urlParams[PARAM_KEY_AFTER] = pagination.after;
  }

  return setUrlParams(urlParams, url, false, true, true);
};

export const fromSearchToVariables = ({ filters = [], sort = null, pagination = {} } = {}) => {
  const variables = {};

  const queryObj = filterToQueryObject(processFilters(filters));

  // TODO Get more than one value when GraphQL API supports OR for "status"
  [variables.status] = queryObj[PARAM_KEY_STATUS] || [];

  // TODO Get more than one value when GraphQL API supports OR for "runner type"
  [variables.type] = queryObj[PARAM_KEY_RUNNER_TYPE] || [];

  if (sort) {
    variables.sort = sort;
  }

  if (pagination.before) {
    variables.before = pagination.before;
    variables.last = RUNNER_PAGE_SIZE;
  } else {
    variables.after = pagination.after;
    variables.first = RUNNER_PAGE_SIZE;
  }

  return variables;
};
