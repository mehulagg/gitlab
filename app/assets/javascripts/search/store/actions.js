import Api from '~/api';
import createFlash from '~/flash';
import AccessorUtilities from '~/lib/utils/accessor';
import { visitUrl, setUrlParams } from '~/lib/utils/url_utility';
import { __ } from '~/locale';
import { MAX_FREQUENT_ITEMS } from './constants';
import * as types from './mutation_types';

export const fetchGroups = ({ commit }, search) => {
  commit(types.REQUEST_GROUPS);
  Api.groups(search)
    .then((data) => {
      commit(types.RECEIVE_GROUPS_SUCCESS, data);
    })
    .catch(() => {
      createFlash({ message: __('There was a problem fetching groups.') });
      commit(types.RECEIVE_GROUPS_ERROR);
    });
};

export const fetchProjects = ({ commit, state }, search) => {
  commit(types.REQUEST_PROJECTS);
  const groupId = state.query?.group_id;
  const callback = (data) => {
    if (data) {
      commit(types.RECEIVE_PROJECTS_SUCCESS, data);
    } else {
      createFlash({ message: __('There was an error fetching projects') });
      commit(types.RECEIVE_PROJECTS_ERROR);
    }
  };

  if (groupId) {
    // TODO (https://gitlab.com/gitlab-org/gitlab/-/issues/323331): For errors `createFlash` is called twice; in `callback` and in `Api.groupProjects`
    Api.groupProjects(groupId, search, {}, callback);
  } else {
    // The .catch() is due to the API method not handling a rejection properly
    Api.projects(search, { order_by: 'id' }, callback).catch(() => {
      callback();
    });
  }
};

export const getFrequentItemLS = ({ commit }, lsKey) => {
  if (!AccessorUtilities.isLocalStorageAccessSafe()) {
    return;
  }

  commit(types.RECEIVE_FREQUENT_ITEMS_LS, { lsKey, data: JSON.parse(localStorage.getItem(lsKey)) });
};

export const setFrequentItemLS = ({ state }, { item, lsKey }) => {
  if (!AccessorUtilities.isLocalStorageAccessSafe()) {
    return;
  }

  const frequentItems = state.frequentItems[lsKey];
  const existingItemIndex = frequentItems.findIndex((i) => i.id === item.id);

  if (existingItemIndex >= 0) {
    // Up the frequency (Max 5)
    const currentFrequency = frequentItems[existingItemIndex].frequency;
    frequentItems[existingItemIndex].frequency =
      currentFrequency < MAX_FREQUENT_ITEMS ? currentFrequency + 1 : MAX_FREQUENT_ITEMS;
  } else {
    // Only store a max of 5 items
    if (frequentItems.length >= MAX_FREQUENT_ITEMS) {
      frequentItems.pop();
    }

    frequentItems.push({ id: item.id, frequency: 1 });
  }

  // Sort by frequency
  frequentItems.sort((a, b) => b.frequency - a.frequency);

  localStorage.setItem(lsKey, JSON.stringify(frequentItems));
};

export const setQuery = ({ commit }, { key, value }) => {
  commit(types.SET_QUERY, { key, value });
};

export const applyQuery = ({ state }) => {
  visitUrl(setUrlParams({ ...state.query, page: null }));
};

export const resetQuery = ({ state }) => {
  visitUrl(setUrlParams({ ...state.query, page: null, state: null, confidential: null }));
};
