import Vue from 'vue';
import App from 'ee/vulnerabilities/components/vulnerability.vue';
import apolloProvider from 'ee/security_dashboard/graphql/provider';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

export default (el) => {
  if (!el) {
    return null;
  }

  const vulnerability = convertObjectPropsToCamelCase(JSON.parse(el.dataset.vulnerability), {
    deep: true,
  });

  return new Vue({
    el,
    apolloProvider,
    provide: {
      reportType: vulnerability.reportType,
      newIssueUrl: vulnerability.newIssueUrl,
      projectFingerprint: vulnerability.projectFingerprint,
      vulnerabilityId: vulnerability.id,
      issueTrackingHelpPath: vulnerability.issueTrackingHelpPath,
      permissionsHelpPath: vulnerability.permissionsHelpPath,
    },
    render: (h) =>
      h(App, {
        props: { vulnerability },
      }),
  });
};
