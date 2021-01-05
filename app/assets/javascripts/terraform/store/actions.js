import * as types from './mutation_types';

export const setStateList = ({ commit }, data) => {
  const list = data?.project?.terraformStates?.nodes;

  commit(types.SET_STATE_LIST, list);
};
