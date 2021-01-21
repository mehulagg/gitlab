import * as actions from './actions';
import * as getters from './getters';
import mutations from './mutations';
import state from './state';

export default (transformFunc) => ({
  namespaced: true,
  actions,
  getters,
  mutations: mutations(transformFunc),
  state,
});
