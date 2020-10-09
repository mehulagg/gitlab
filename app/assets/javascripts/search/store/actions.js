import Api from '~/api';
import createFlash from '~/flash';
import { sprintf, __ } from '~/locale';
import * as types from './mutation_types';

export const fetchInitialGroup = ({ commit }, groupId) => {
  commit(types.REQUEST_INITIAL_GROUP);
  Api.group(groupId)
    .then(data => {
      commit(types.RECEIVE_INITIAL_GROUP_SUCCESS, data);
    })
    .catch(() => {
      createFlash({
        message: sprintf(__('There was an error fetching initial group id: %{groupId}'), {
          groupId,
        }),
      });
      commit(types.RECEIVE_INITIAL_GROUP_ERROR);
    });
};

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
