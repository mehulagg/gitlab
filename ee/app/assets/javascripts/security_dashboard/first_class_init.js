import Vue from 'vue';
import { DASHBOARD_TYPES } from 'ee/security_dashboard/store/constants';
import { parseBoolean } from '~/lib/utils/common_utils';
import FirstClassGroupSecurityDashboard from './components/first_class_group_security_dashboard.vue';
import FirstClassInstanceSecurityDashboard from './components/first_class_instance_security_dashboard.vue';
import FirstClassProjectSecurityDashboard from './components/first_class_project_security_dashboard.vue';
import UnavailableState from './components/unavailable_state.vue';
import apolloProvider from './graphql/provider';
import createRouter from './router';
import createStore from './store';

export default (el, dashboardType) => {
  if (!el) {
    return null;
  }

  const {
    isUnavailable,
    dashboardDocumentation,
    emptyStateSvgPath,
    noVulnerabilitiesSvgPath,
    notEnabledScannersHelpPath,
    noPipelineRunScannersHelpPath,
    hasVulnerabilities,
    scanners,
    securityDashboardHelpPath,
    projectAddEndpoint,
    projectListEndpoint,
    vulnerabilitiesExportEndpoint,
    projectFullPath,
    autoFixDocumentation,
    autoFixMrsPath,
    groupFullPath,
    instanceDashboardSettingsPath,
    pipelineCreatedAt,
    pipelineId,
    pipelinePath,
    pipelineSecurityBuildsFailedCount,
    pipelineSecurityBuildsFailedPath,
    hasJiraVulnerabilitiesIntegrationEnabled,
    securityConfigurationPath,
    hasProjects,
  } = el.dataset;

  console.log(el.dataset);

  if (isUnavailable) {
    return new Vue({
      el,
      render(createElement) {
        return createElement(UnavailableState, {
          props: {
            link: dashboardDocumentation,
            svgPath: emptyStateSvgPath,
          },
        });
      },
    });
  }

  const provide = {
    dashboardDocumentation,
    noVulnerabilitiesSvgPath,
    emptyStateSvgPath,
    notEnabledScannersHelpPath,
    noPipelineRunScannersHelpPath,
    groupFullPath,
    securityConfigurationPath,
    hasProjects: parseBoolean(hasProjects),
    hasVulnerabilities: parseBoolean(hasVulnerabilities),
    scanners: scanners ? JSON.parse(scanners) : [],
    hasJiraVulnerabilitiesIntegrationEnabled: parseBoolean(
      hasJiraVulnerabilitiesIntegrationEnabled,
    ),
  };

  const props = {
    securityDashboardHelpPath,
    projectAddEndpoint,
    projectListEndpoint,
    vulnerabilitiesExportEndpoint,
  };

  let component;

  if (dashboardType === DASHBOARD_TYPES.PROJECT) {
    component = FirstClassProjectSecurityDashboard;
    props.pipeline = {
      createdAt: pipelineCreatedAt,
      id: pipelineId,
      path: pipelinePath,
      securityBuildsFailedCount: Number(pipelineSecurityBuildsFailedCount),
      securityBuildsFailedPath: pipelineSecurityBuildsFailedPath,
    };
    provide.projectFullPath = projectFullPath;
    provide.autoFixDocumentation = autoFixDocumentation;
    provide.autoFixMrsPath = autoFixMrsPath;
  } else if (dashboardType === DASHBOARD_TYPES.GROUP) {
    component = FirstClassGroupSecurityDashboard;
  } else if (dashboardType === DASHBOARD_TYPES.INSTANCE) {
    provide.instanceDashboardSettingsPath = instanceDashboardSettingsPath;
    component = FirstClassInstanceSecurityDashboard;
  }

  const router = createRouter();
  const store = createStore({ dashboardType });

  return new Vue({
    el,
    store,
    router,
    apolloProvider,
    provide,
    render(createElement) {
      return createElement(component, { props });
    },
  });
};
