import Vue from 'vue';
import MainApp from 'ee/vulnerabilities/components/vulnerability.vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

(function createMainApp() {
  const el = document.getElementById('js-vulnerability-main');
  const vulnerability = convertObjectPropsToCamelCase(JSON.parse(el.dataset.vulnerability), {
    deep: true,
  });

  return new Vue({
    el,

    provide: {
      reportType: vulnerability.reportType,
      createIssueUrl: vulnerability.createIssueUrl,
      projectFingerprint: vulnerability.projectFingerprint,
      vulnerabilityId: vulnerability.id,
      issueTrackingHelpPath: vulnerability.issueTrackingHelpPath,
      permissionsHelpPath: vulnerability.permissionsHelpPath,
    },

    render: h =>
      h(MainApp, {
        props: { vulnerability },
      }),
  });
})();
