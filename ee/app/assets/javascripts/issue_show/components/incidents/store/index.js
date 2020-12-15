import Vuex from 'vuex';
import state from './state';
import * as actions from './actions';
import mutations from './mutations';

export default initialState =>
  new Vuex.Store({
    actions,
    mutations,
    state: state(initialState),
  });
