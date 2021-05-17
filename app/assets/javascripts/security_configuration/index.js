import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import SecurityConfigurationApp from './components/app.vue';
import NewSecurityConfigurationApp from './components/new_app.vue';
import { augmentFeatures } from './utils';

export const initStaticSecurityConfiguration = (el) => {
  if (!el) {
    return null;
  }

  Vue.use(VueApollo);

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  const { projectPath, upgradePath, features } = el.dataset;

  if (gon.features.securityConfigurationRedesign) {
    const { securityFeatures, complianceFeatures } = augmentFeatures(features);

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
            securityFeatures,
            complianceFeatures,
          },
        });
      },
    });
  }

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
