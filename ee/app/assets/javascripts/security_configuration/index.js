import Vue from 'vue';
import { parseBooleanDataAttributes } from '~/lib/utils/dom_utils';
import SecurityConfigurationApp from './components/app.vue';

export default function init() {
  const el = document.getElementById('js-security-configuration');
  const {
    autoDevopsHelpPagePath,
    autoDevopsPath,
    features,
    helpPagePath,
    latestPipelinePath,
    autoFixEnabled,
    autoFixHelpPath,
    autoFixUserPath,
    containerScanningHelpPath,
    dependencyScanningHelpPath,
    toggleAutofixSettingEndpoint,
    createSastMergeRequestPath,
    gitlabCiHistoryPath,
  } = el.dataset;

  return new Vue({
    el,
    components: {
      SecurityConfigurationApp,
    },
    render(createElement) {
      return createElement(SecurityConfigurationApp, {
        props: {
          autoDevopsHelpPagePath,
          autoDevopsPath,
          features: JSON.parse(features),
          helpPagePath,
          latestPipelinePath,
          createSastMergeRequestPath,
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
}
