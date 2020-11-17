import Vue from 'vue';
import MainApp from 'ee/vulnerabilities/components/vulnerability.vue';

(function createMainApp() {
  const el = document.getElementById('js-vulnerability-main');
  const vulnerability = JSON.parse(el.dataset.vulnerability);

  return new Vue({
    el,

    provide: {
      reportType: vulnerability.report_type,
      createIssueUrl: vulnerability.create_issue_url,
      projectFingerprint: vulnerability.project_fingerprint,
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
