import Api from '~/api';
import createFlash from '~/flash';
import { visitUrl, setUrlParams } from '~/lib/utils/url_utility';
import { __ } from '~/locale';
import { GROUPS_LOCAL_STORAGE_KEY, PROJECTS_LOCAL_STORAGE_KEY } from './constants';
import * as types from './mutation_types';
import { loadDataFromLS, setFrequentItemToLS } from './utils';

export const fetchGroups = ({ commit }, search) => {
  commit(types.REQUEST_GROUPS);
  Api.groups(search, { order_by: 'similarity' })
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
    Api.groupProjects(groupId, search, { order_by: 'similarity' }, callback);
  } else {
    // The .catch() is due to the API method not handling a rejection properly
    Api.projects(search, { order_by: 'id' }, callback).catch(() => {
      callback();
    });
  }
};

export const loadFrequentGroups = ({ commit }) => {
  commit(types.REQUEST_FREQUENT_GROUPS);
  const lsData = loadDataFromLS(GROUPS_LOCAL_STORAGE_KEY);
  const promises = lsData.map((d) => Api.group(d.id));

  Promise.all(promises)
    .then((res) => {
      const inflatedData = res.map((inflated) => {
        return { ...inflated, ...lsData.find((d) => d.id === inflated.id) };
      });
      commit(types.RECEIVE_FREQUENT_GROUPS_SUCCESS, inflatedData);
    })
    .catch(() => {
      createFlash({ message: __('There was a problem fetching recent groups.') });
      commit(types.RECEIVE_FREQUENT_GROUPS_ERROR);
    });
};

export const loadFrequentProjects = ({ commit }) => {
  commit(types.REQUEST_FREQUENT_PROJECTS);
  const lsData = loadDataFromLS(PROJECTS_LOCAL_STORAGE_KEY);
  const promises = lsData.map((d) => Api.project(d.id));

  Promise.all(promises)
    .then((res) => {
      const resData = res.map((r) => r.data);
      const inflatedData = resData.map((inflated) => {
        return { ...inflated, ...lsData.find((d) => d.id === inflated.id) };
      });
      commit(types.RECEIVE_FREQUENT_PROJECTS_SUCCESS, inflatedData);
    })
    .catch(() => {
      createFlash({ message: __('There was a problem fetching recent projects.') });
      commit(types.RECEIVE_FREQUENT_PROJECTS_ERROR);
    });
};

export const setFrequentGroup = ({ state }, item) => {
  setFrequentItemToLS(GROUPS_LOCAL_STORAGE_KEY, state.frequentItems, item);
};

export const setFrequentProject = ({ state }, item) => {
  setFrequentItemToLS(PROJECTS_LOCAL_STORAGE_KEY, state.frequentItems, item);
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
