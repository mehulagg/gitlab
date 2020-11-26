import createState from './state';
import mutations from './mutations';
import * as getters from './getters';

export default () => ({
  state: createState(),
  mutations,
  getters,
});
