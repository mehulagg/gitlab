import * as types from './mutation_types';

export const setStateError = ({ state, commit }, { id, errorMessage }) => {
  const list = state.statesList.map((terraformState) => {
    if (terraformState.id === id) {
      return {
        ...terraformState,
        errorMessage,
        _showDetails: true,
      };
    }

    return terraformState;
  });

  commit(types.SET_STATE_LIST, list);
};

export const setStateList = ({ commit }, data) => {
  let list = data?.project?.terraformStates?.nodes;

  if (list) {
    list = list.map((terraformState) => {
      return {
        ...terraformState,
        _showDetails: false,
        loadingActions: false,
        errorMessage: null,
      };
    });
  }

  commit(types.SET_STATE_LIST, list);
};

export const setStateLoading = ({ state, commit }, stateID) => {
  const list = state.statesList.map((terraformState) => {
    if (terraformState.id === stateID) {
      return {
        ...terraformState,
        loadingActions: true,
      };
    }

    return terraformState;
  });

  commit(types.SET_STATE_LIST, list);
};
