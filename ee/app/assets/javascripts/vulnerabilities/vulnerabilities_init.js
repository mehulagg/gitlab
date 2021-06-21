import Vue from 'vue';
import apolloProvider from 'ee/security_dashboard/graphql/provider';
import App from 'ee/vulnerabilities/components/vulnerability.vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

export default (el) => {
  if (!el) {
    return null;
  }

  const { vulnerability: rawVulnerability, projectCommitPath } = el.dataset;

  const vulnerability = convertObjectPropsToCamelCase(JSON.parse(rawVulnerability), {
    deep: true,
  });

  return new Vue({
    el,
    apolloProvider,
    provide: {
      reportType: vulnerability.reportType,
      newIssueUrl: vulnerability.newIssueUrl,
      projectCommitPath,
      projectFingerprint: vulnerability.projectFingerprint,
      projectFullPath: vulnerability.project?.fullPath,
      vulnerabilityId: vulnerability.id,
      issueTrackingHelpPath: vulnerability.issueTrackingHelpPath,
      permissionsHelpPath: vulnerability.permissionsHelpPath,
      createJiraIssueUrl: vulnerability.createJiraIssueUrl,
      relatedJiraIssuesPath: vulnerability.relatedJiraIssuesPath,
      relatedJiraIssuesHelpPath: vulnerability.relatedJiraIssuesHelpPath,
      jiraIntegrationSettingsPath: vulnerability.jiraIntegrationSettingsPath,
    },
    render: (h) =>
      h(App, {
        props: { vulnerability },
      }),
  });
};
