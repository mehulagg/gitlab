import * as actions from './actions';
import mutations from './mutations';
import state from './state';

export default (initState = {}) => ({
  actions,
  mutations,
  state: state(initState),
});
