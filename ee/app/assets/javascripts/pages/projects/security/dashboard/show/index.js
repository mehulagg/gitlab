import Vue from 'vue';
import createStore from 'ee/vue_shared/security_reports/store';
import SecurityReportApp from 'ee/vue_shared/security_reports/card_security_reports_app.vue';
import { parseBoolean } from '~/lib/utils/common_utils';

document.addEventListener('DOMContentLoaded', () => {
  const securityTab = document.getElementById('js-security-report-app');

  const {
    hasPipelineData,
    userPath,
    userAvatarPath,
    pipelineCreated,
    pipelinePath,
    userName,
    commitId,
    commitPath,
    refId,
    refPath,
    pipelineId,
    createVulnerabilityFeedbackIssuePath,
    createVulnerabilityFeedbackMergeRequestPath,
    createVulnerabilityFeedbackDismissalPath,
    ...rest
  } = securityTab.dataset;

  const parsedPipelineId = parseInt(pipelineId, 10);

  const store = createStore();

  return new Vue({
    el: securityTab,
    store,
    components: {
      SecurityReportApp,
    },
    methods: {},
    render(createElement) {
      return createElement('security-report-app', {
        props: {
          pipelineId: parsedPipelineId,
          hasPipelineData: parseBoolean(hasPipelineData),
          canCreateIssue: Boolean(createVulnerabilityFeedbackIssuePath),
          canCreateMergeRequest: Boolean(createVulnerabilityFeedbackMergeRequestPath),
          canDismissVulnerability: Boolean(createVulnerabilityFeedbackDismissalPath),
          createVulnerabilityFeedbackIssuePath,
          createVulnerabilityFeedbackMergeRequestPath,
          createVulnerabilityFeedbackDismissalPath,
          triggeredBy: {
            avatarPath: userAvatarPath,
            name: userName,
            path: userPath,
          },
          pipeline: {
            id: parsedPipelineId,
            created: pipelineCreated,
            path: pipelinePath,
          },
          commit: {
            id: commitId,
            path: commitPath,
          },
          branch: {
            id: refId,
            path: refPath,
          },
          ...rest,
        },
      });
    },
  });
});
