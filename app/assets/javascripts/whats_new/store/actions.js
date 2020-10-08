import * as types from './mutation_types';
import axios from '~/lib/utils/axios_utils';
import { normalizeHeaders } from '~/lib/utils/common_utils';

export default {
  closeDrawer({ commit }) {
    commit(types.CLOSE_DRAWER);
  },
  openDrawer({ commit }, storageKey) {
    commit(types.OPEN_DRAWER);

    if (storageKey) {
      localStorage.setItem(storageKey, JSON.stringify(false));
    }
  },
  fetchItems({ commit, state}, page) {
    return axios.get('/-/whats_new', {
      params: {
        page: page
      }
    }).then(({ data, headers }) => {
      commit(types.SET_FEATURES, data);

      const nextPage = parseInt(normalizeHeaders(headers)['X-NEXT-PAGE'], 10) || null;
      const currentPage = parseInt(normalizeHeaders(headers)['X-PAGE'], 10);

      commit(types.SET_PAGINATION, {
        nextPage: nextPage,
        currentPage: currentPage
      });
    });
  },
  bottomReached({ commit, dispatch, state }) {
    if(state.pageInfo.nextPage) {
      dispatch('fetchItems', state.pageInfo.nextPage);
    }
  },
};
