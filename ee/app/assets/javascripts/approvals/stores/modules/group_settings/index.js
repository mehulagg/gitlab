import * as actions from './actions';
import mutations from './mutations';
import createState from './state';

export default () => ({
  state: createState(),
  actions,
  mutations,
});
