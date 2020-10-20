import Api from '~/api';
import createFlash from '~/flash';
import { __ } from '~/locale';
import * as types from './mutation_types';

export const fetchGroups = ({ commit }, search) => {
  commit(types.REQUEST_GROUPS);
  Api.groups(search)
    .then(data => {
      commit(types.RECEIVE_GROUPS_SUCCESS, data);
    })
    .catch(() => {
      createFlash({ message: __('There was an error fetching Groups') });
      commit(types.RECEIVE_GROUPS_ERROR);
    });
};

const getProjectsData = (state, search) => {
  const groupId = state.query?.group_id;

  return new Promise(resolve => {
    if (groupId) {
      Api.groupProjects(groupId, search, {}, resolve);
    } else {
      Api.projects(search, { order_by: 'id' }, resolve);
    }
  });
};

export const fetchProjects = ({ commit, state }, search) => {
  commit(types.REQUEST_PROJECTS);
  getProjectsData(state, search)
    .then(data => {
      commit(types.RECEIVE_PROJECTS_SUCCESS, data);
    })
    .catch(() => {
      createFlash({ message: __('There was an error fetching Projects') });
      commit(types.RECEIVE_PROJECTS_ERROR);
    });
};
