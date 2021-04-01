import * as Sentry from '@sentry/browser';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import showToast from '~/vue_shared/plugins/global_toast';
import {
  SET_INITIAL_DATA,
  FETCH_AWARDS_SUCCESS,
  ADD_NEW_AWARD,
  REMOVE_AWARD,
} from './mutation_types';

export const setInitialData = ({ commit }, data) => commit(SET_INITIAL_DATA, data);

export const fetchAwards = async ({ commit, state }) => {
  try {
    const { data } = await axios.get(state.path, { params: { per_page: 100 } });

    commit(FETCH_AWARDS_SUCCESS, data);
  } catch (error) {
    Sentry.captureException(error);
  }
};

export const toggleAward = async ({ commit, state }, name) => {
  const award = state.awards.find((a) => a.name === name && a.user.id === state.currentUserId);

  try {
    if (award) {
      await axios.delete(`${state.path}/${award.id}`);

      commit(REMOVE_AWARD, award.id);

      showToast(__('Award removed'));
    } else {
      const { data } = await axios.post(state.path, { name });

      commit(ADD_NEW_AWARD, data);

      showToast(__('Award added'));
    }
  } catch (error) {
    Sentry.captureException(error);
  }
};
