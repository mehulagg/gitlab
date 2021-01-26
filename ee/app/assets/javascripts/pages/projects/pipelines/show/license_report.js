import Vue from 'vue';
import LicenseReportApp from 'ee/vue_shared/license_compliance/mr_widget_license_report.vue';
import Translate from '~/vue_shared/translate';
import { parseBoolean } from '~/lib/utils/common_utils';
import { updateBadgeCount } from './utils';

Vue.use(Translate);

export default () => {
  const licensesTab = document.getElementById('js-licenses-app');

  if (licensesTab) {
    const {
      canManageLicenses,
      apiUrl,
      licenseManagementSettingsPath,
      licensesApiPath,
    } = licensesTab.dataset;

    // eslint-disable-next-line no-new
    new Vue({
      el: licensesTab,
      components: {
        LicenseReportApp,
      },
      render(createElement) {
        return createElement('license-report-app', {
          props: {
            apiUrl,
            licensesApiPath,
            licenseManagementSettingsPath,
            canManageLicenses: parseBoolean(canManageLicenses),
            alwaysOpen: true,
            reportSectionClass: 'split-report-section',
          },
          on: {
            updateBadgeCount: (count) => {
              updateBadgeCount('.js-licenses-counter', count);
            },
          },
        });
      },
    });
  }
};
