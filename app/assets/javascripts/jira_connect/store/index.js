import Vuex from 'vuex';
import * as actions from './actions';
import mutations from './mutations';
import state from './state';

export default () =>
  new Vuex.Store({
    actions,
    mutations,
    state,
  });
