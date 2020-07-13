import Vue from 'vue';
import Vuex from 'vuex';
import * as actions from './actions';
import * as getters from './getters';
import mutations from './mutations';
import createState from './state';

Vue.use(Vuex);

const createStore = ({ replicableType, graphqlFieldName }) =>
  new Vuex.Store({
    actions,
    getters,
    mutations,
    state: createState({ replicableType, graphqlFieldName }),
  });
export default createStore;
