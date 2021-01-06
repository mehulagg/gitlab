import Vue from 'vue';

export const store = Vue.observable({
  errorMessage: '',
});

export const mutations = {
  setErrorMessage(errorMessage) {
    store.errorMessage = errorMessage;
  },
};
