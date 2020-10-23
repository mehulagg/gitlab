import createState from './state';
import mutations from './mutations';
import * as actions from './actions';

export default ({ securityConfigurationPath = '' }) => ({
  namespaced: true,
  state: createState({ securityConfigurationPath }),
  mutations,
  actions,
});
