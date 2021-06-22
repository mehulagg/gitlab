import { setUrlParams, queryToObject, visitUrl } from '~/lib/utils/url_utility';
import { parseAuditEventSearchQuery, createAuditEventSearchQuery } from '../utils';
import * as types from './mutation_types';

export const initializeAuditEvents = ({ commit }) => {
  commit(
    types.INITIALIZE_AUDIT_EVENTS,
    parseAuditEventSearchQuery(queryToObject(window.location.search, { legacySpacesDecode: true })),
  );
};

export const searchForAuditEvents = ({ state }) => {
  visitUrl(setUrlParams(createAuditEventSearchQuery(state)));
};

export const setDateRange = ({ commit, dispatch }, { startDate, endDate }) => {
  commit(types.SET_DATE_RANGE, { startDate, endDate });
  dispatch('searchForAuditEvents');
};

export const setFilterValue = ({ commit }, filterValue) => {
  commit(types.SET_FILTER_VALUE, filterValue);
};

export const setSortBy = ({ commit, dispatch }, sortBy) => {
  commit(types.SET_SORT_BY, sortBy);
  dispatch('searchForAuditEvents');
};
