import state from './state';
// import mutations from './mutations';
import * as actions from './actions';

export default (initialState = {}) => ({
  actions,
  mutations: {},
  state: state(initialState),
});
