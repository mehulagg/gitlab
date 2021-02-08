import * as actions from './actions';
import createState from './state';
import mutations from './mutations';

export default () => ({
  state: createState(),
  actions,
  mutations,
});
