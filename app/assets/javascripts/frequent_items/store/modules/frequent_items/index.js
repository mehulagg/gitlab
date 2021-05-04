import * as actions from './actions';
import * as getters from './getters';
import mutations from './mutations';
import state from './state';

export default (initState = {}) => ({
  namespaced: true,
  actions,
  getters,
  mutations,
  state: state(initState),
});
