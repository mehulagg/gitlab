import Vue from 'vue';
import Vuex from 'vuex';
import createState from './state';

Vue.use(Vuex);

export const getStoreConfig = ({ scope, query }) => ({
  state: createState({ scope, query }),
});

const createStore = config => new Vuex.Store(getStoreConfig(config));
export default createStore;
