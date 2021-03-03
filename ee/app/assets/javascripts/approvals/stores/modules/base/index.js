import * as getters from './getters';
import mutations from './mutations';
import createState from './state';

export default () => ({
  state: createState(),
  mutations,
  getters,
});
