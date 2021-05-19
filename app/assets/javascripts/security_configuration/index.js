import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { parseBooleanDataAttributes } from '~/lib/utils/dom_utils';
import SecurityConfigurationApp from './components/app.vue';
import NewSecurityConfigurationApp from './components/new_app.vue';
import { augmentFeatures } from './utils';

export const initNewSecurityConfiguration = (el) => {
  if (!el) {
    return null;
  }

  Vue.use(VueApollo);

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  const {
    upgradePath,
    features,
    autoDevopsHelpPagePath,
    autoDevopsPath,
    latestPipelinePath,
    projectPath,
    gitlabCiHistoryPath,
  } = el.dataset;

  const { securityFeatures, complianceFeatures } = augmentFeatures(
    features ? JSON.parse(features) : [],
  );

  return new Vue({
    el,
    apolloProvider,
    provide: {
      projectPath,
      upgradePath,
    },
    render(createElement) {
      return createElement(NewSecurityConfigurationApp, {
        props: {
          ...parseBooleanDataAttributes(el, [
            'autoDevopsEnabled',
            'canEnableAutoDevops',
            'gitlabCiPresent',
          ]),
          autoDevopsHelpPagePath,
          autoDevopsPath,
          latestPipelinePath,
          projectPath,
          gitlabCiHistoryPath,
          securityFeatures,
          complianceFeatures,
        },
      });
    },
  });
};

export const initStaticSecurityConfiguration = (el) => {
  if (!el) {
    return null;
  }

  Vue.use(VueApollo);

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  const { projectPath, upgradePath } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    provide: {
      projectPath,
      upgradePath,
    },
    render(createElement) {
      return createElement(SecurityConfigurationApp);
    },
  });
};
