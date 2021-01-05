export const setStateList = ({ commit }, data) => {
  const list = data?.project?.terraformStates?.nodes;
  // commit(types.SET_STATE_LIST, list);
};
