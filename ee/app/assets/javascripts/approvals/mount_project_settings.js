import Vue from 'vue';
import Vuex from 'vuex';
import { parseBoolean } from '~/lib/utils/common_utils';
import createStore from './stores';
import projectSettingsModule from './stores/modules/project_settings';
import ProjectSettingsApp from './components/project_settings/app.vue';

Vue.use(Vuex);

export default function mountProjectSettingsApprovals(el) {
  if (!el) {
    return null;
  }

  const { vulnerabilityCheckHelpPagePath, licenseCheckHelpPagePath } = el.dataset;

  const store = createStore(projectSettingsModule(), {
    ...el.dataset,
    prefix: 'project-settings',
    allowMultiRule: parseBoolean(el.dataset.allowMultiRule),
    canEdit: parseBoolean(el.dataset.canEdit),
  });

  return new Vue({
    el,
    store,
    provide: {
      vulnerabilityCheckHelpPagePath,
      licenseCheckHelpPagePath,
    },
    render(h) {
      return h(ProjectSettingsApp);
    },
  });
}
