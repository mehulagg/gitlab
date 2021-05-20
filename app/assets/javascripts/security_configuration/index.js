import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { securityFeatures } from '~/security_configuration/components/constants';
import SecurityConfigurationApp from './components/app.vue';
import RedesignedSecurityConfigurationApp from './components/redesigned_app.vue';
import { augmentFeatures } from './utils';

export const initStaticSecurityConfiguration = (el) => {
  if (!el) {
    return null;
  }

  Vue.use(VueApollo);

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  const { projectPath, upgradePath } = el.dataset;

  const features = securityFeatures;

  if (gon.features.securityConfigurationRedesign) {
    const { augmentedSecurityFeatures } = augmentFeatures(features);

    return new Vue({
      el,
      apolloProvider,
      provide: {
        projectPath,
        upgradePath,
      },
      render(createElement) {
        return createElement(RedesignedSecurityConfigurationApp, {
          props: {
            augmentedSecurityFeatures,
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
