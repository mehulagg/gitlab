import * as types from './mutation_types';

export const setStateError = ({ state, commit }, { id, errorMessages }) => {
  const list = state.statesList.map((terraformState) => {
    if (terraformState.id === id) {
      return {
        ...terraformState,
        errorMessages,
        _showDetails: true,
        loadingActions: false,
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
        errorMessages: [],
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
        _showDetails: false,
        errorMessages: [],
        loadingActions: true,
      };
    }

    return terraformState;
  });

  commit(types.SET_STATE_LIST, list);
};
