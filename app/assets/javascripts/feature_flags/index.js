import Vue from 'vue';
import Vuex from 'vuex';
import csrf from '~/lib/utils/csrf';
import FeatureFlagsComponent from './components/feature_flags.vue';
import createStore from './store/index';

Vue.use(Vuex);

export default () => {
  const el = document.querySelector('#feature-flags-vue');

  const {
    projectName,
    featureFlagsHelpPagePath,
    errorStateSvgPath,
    endpoint,
    projectId,
    unleashApiInstanceId,
    rotateInstanceIdPath,
    featureFlagsClientLibrariesHelpPagePath,
    featureFlagsClientExampleHelpPagePath,
    unleashApiUrl,
    csrfToken,
    canUserConfigure,
    newFeatureFlagPath,
    newUserListPath,
  } = el.dataset;

  return new Vue({
    el,
    store: createStore({ endpoint, projectId, unleashApiInstanceId, rotateInstanceIdPath }),
    provide: {
      projectName,
      featureFlagsHelpPagePath,
      errorStateSvgPath,
      featureFlagsClientLibrariesHelpPagePath,
      featureFlagsClientExampleHelpPagePath,
      unleashApiUrl,
      csrfToken,
      canUserConfigure,
      newFeatureFlagPath,
      newUserListPath,
    },
    render(createElement) {
      return createElement(FeatureFlagsComponent);
    },
  });
};
