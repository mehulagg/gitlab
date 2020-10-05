import Vue from 'vue';
import createDashboardStore from './store';
import PipelineSecurityDashboard from './components/pipeline_security_dashboard.vue';
import { DASHBOARD_TYPES } from './store/constants';
import { LOADING_VULNERABILITIES_ERROR_CODES } from './store/modules/vulnerabilities/constants';
import apolloProvider from './graphql/provider';

export default () => {
  const el = document.getElementById('js-security-report-app');

  if (!el) {
    return null;
  }

  const {
    dashboardDocumentation,
    emptyStateSvgPath,
    pipelineId,
    pipelineIid,
    projectId,
    sourceBranch,
    vulnerabilitiesEndpoint,
    vulnerabilityFeedbackHelpPath,
    emptyStateUnauthorizedSvgPath,
    emptyStateForbiddenSvgPath,
    projectFullPath,
    pipelineJobsPath,
  } = el.dataset;

  const loadingErrorIllustrations = {
    [LOADING_VULNERABILITIES_ERROR_CODES.UNAUTHORIZED]: emptyStateUnauthorizedSvgPath,
    [LOADING_VULNERABILITIES_ERROR_CODES.FORBIDDEN]: emptyStateForbiddenSvgPath,
  };

  return new Vue({
    el,
    apolloProvider,
    store: createDashboardStore({
      dashboardType: DASHBOARD_TYPES.PIPELINE,
    }),
    render(createElement) {
      return createElement(PipelineSecurityDashboard, {
        props: {
          projectId: parseInt(projectId, 10),
          pipelineId: parseInt(pipelineId, 10),
          pipelineIid: parseInt(pipelineIid, 10),
          vulnerabilitiesEndpoint,
          vulnerabilityFeedbackHelpPath,
          sourceBranch,
          dashboardDocumentation,
          emptyStateSvgPath,
          loadingErrorIllustrations,
          projectFullPath,
          pipelineJobsPath,
        },
      });
    },
  });
};
