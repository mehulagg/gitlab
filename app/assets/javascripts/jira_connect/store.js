import Vuex from 'vuex';

export const MUTATION_TYPES = {
  PUT_ERROR_MESSAGE: 'PUT_ERROR_MESSAGE',
};

export const createStore = () =>
  new Vuex.Store({
    state: {
      errorMessage: '',
    },
    mutations: {
      [MUTATION_TYPES.PUT_ERROR_MESSAGE](state, errorMessage) {
        state.errorMessage = errorMessage;
      },
    },
  });
