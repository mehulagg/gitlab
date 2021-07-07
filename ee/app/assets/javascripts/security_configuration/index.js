import Vue from 'vue';
import { parseBooleanDataAttributes } from '~/lib/utils/dom_utils';
import { initRedesignedSecurityConfiguration } from '~/security_configuration';
import SecurityConfigurationApp from './components/app.vue';

export const initSecurityConfiguration = (el) => {
  if (!el) {
    return null;
  }

  if (gon.features?.securityConfigurationRedesignEE) {
    return initRedesignedSecurityConfiguration(el);
  }

  const {
    autoDevopsHelpPagePath,
    autoDevopsPath,
    features,
    latestPipelinePath,
    autoFixEnabled,
    autoFixHelpPath,
    autoFixUserPath,
    containerScanningHelpPath,
    dependencyScanningHelpPath,
    toggleAutofixSettingEndpoint,
    projectPath,
    gitlabCiHistoryPath,
  } = el.dataset;

  return new Vue({
    el,
    components: {
      SecurityConfigurationApp,
    },
    provide: {
      projectPath,
    },
    render(createElement) {
      return createElement(SecurityConfigurationApp, {
        props: {
          autoDevopsHelpPagePath,
          autoDevopsPath,
          features: JSON.parse(features),
          latestPipelinePath,
          ...parseBooleanDataAttributes(el, [
            'autoDevopsEnabled',
            'canEnableAutoDevops',
            'gitlabCiPresent',
          ]),
          gitlabCiHistoryPath,
          autoFixSettingsProps: {
            autoFixEnabled: JSON.parse(autoFixEnabled),
            autoFixHelpPath,
            autoFixUserPath,
            containerScanningHelpPath,
            dependencyScanningHelpPath,
            toggleAutofixSettingEndpoint,
            ...parseBooleanDataAttributes(el, ['canToggleAutoFixSettings']),
          },
        },
      });
    },
  });
};
