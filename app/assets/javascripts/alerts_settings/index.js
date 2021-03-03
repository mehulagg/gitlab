import { GlToast } from '@gitlab/ui';
import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import AlertSettingsWrapper from './components/alerts_settings_wrapper.vue';
import apolloProvider from './graphql';

apolloProvider.clients.defaultClient.cache.writeData({
  data: {
    currentIntegration: null,
  },
});
Vue.use(GlToast);

export default (el) => {
  if (!el) {
    return null;
  }

  const {
    prometheusActivated,
    prometheusUrl,
    prometheusAuthorizationKey,
    prometheusFormPath,
    prometheusResetKeyPath,
    prometheusApiUrl,
    activated: activatedStr,
    alertsSetupUrl,
    alertsUsageUrl,
    formPath,
    authorizationKey,
    url,
    projectPath,
    multiIntegrations,
    alertFields,
  } = el.dataset;

  return new Vue({
    el,
    components: {
      AlertSettingsWrapper,
    },
    provide: {
      prometheus: {
        active: parseBoolean(prometheusActivated),
        url: prometheusUrl,
        token: prometheusAuthorizationKey,
        prometheusFormPath,
        prometheusResetKeyPath,
        prometheusApiUrl,
      },
      generic: {
        alertsSetupUrl,
        alertsUsageUrl,
        active: parseBoolean(activatedStr),
        formPath,
        token: authorizationKey,
        url,
      },
      projectPath,
      multiIntegrations: parseBoolean(multiIntegrations),
    },
    apolloProvider,
    render(createElement) {
      return createElement('alert-settings-wrapper', {
        props: {
          alertFields:
            gon.features?.multipleHttpIntegrationsCustomMapping && parseBoolean(multiIntegrations)
              ? JSON.parse(alertFields)
              : null,
        },
      });
    },
  });
};
