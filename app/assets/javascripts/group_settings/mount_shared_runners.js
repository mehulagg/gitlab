import Vue from 'vue';
import UpdateSharedRunnersForm from './components/shared_runners_form.vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

export default (containerId = 'update-shared-runners-form') => {
  const containerEl = document.getElementById(containerId);

  const {
    enabled: initEnabled,
    allowOverride: initAllowOverride,
    ...settings
  } = convertObjectPropsToCamelCase(JSON.parse(containerEl.dataset.settings));

  if (!containerEl) {
    return null;
  }

  return new Vue({
    el: containerEl,
    render(createElement) {
      return createElement(UpdateSharedRunnersForm, {
        props: {
          ...settings,
          initEnabled,
          initAllowOverride,
        },
      });
    },
  });
};
