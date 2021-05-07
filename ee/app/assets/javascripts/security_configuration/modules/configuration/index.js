import * as actions from './actions';
import mutations from './mutations';
import createState from './state';

export default ({ securityConfigurationPath = '' }) => ({
  namespaced: true,
  state: createState({ securityConfigurationPath }),
  mutations,
  actions,
});
