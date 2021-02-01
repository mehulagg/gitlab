import Vue from 'vue';
import { DASHBOARD_TYPES } from 'ee/security_dashboard/store/constants';
import { parseBoolean } from '~/lib/utils/common_utils';
import FirstClassProjectSecurityDashboard from './components/first_class_project_security_dashboard.vue';
import FirstClassGroupSecurityDashboard from './components/first_class_group_security_dashboard.vue';
import FirstClassInstanceSecurityDashboard from './components/first_class_instance_security_dashboard.vue';
import UnavailableState from './components/unavailable_state.vue';
import createStore from './store';
import createRouter from './router';
import apolloProvider from './graphql/provider';

export default (el, dashboardType) => {
  if (!el) {
    return null;
  }

  if (el.dataset.isUnavailable) {
    return new Vue({
      el,
      render(createElement) {
        return createElement(UnavailableState, {
          props: {
            link: el.dataset.dashboardDocumentation,
            svgPath: el.dataset.emptyStateSvgPath,
          },
        });
      },
    });
  }

  const provide = {};
  const props = {
    securityDashboardHelpPath: el.dataset.securityDashboardHelpPath,
    projectAddEndpoint: el.dataset.projectAddEndpoint,
    projectListEndpoint: el.dataset.projectListEndpoint,
    vulnerabilitiesExportEndpoint: el.dataset.vulnerabilitiesExportEndpoint,
  };

  let component;

  if (dashboardType === DASHBOARD_TYPES.PROJECT) {
    component = FirstClassProjectSecurityDashboard;
    const {
      pipelineCreatedAt: createdAt,
      pipelineId: id,
      pipelinePath: path,
      pipelineSecurityBuildsFailedCount: securityBuildsFailedCount,
      pipelineSecurityBuildsFailedPath: securityBuildsFailedPath,
    } = el.dataset;
    props.pipeline = {
      createdAt,
      id,
      path,
      securityBuildsFailedCount: Number(securityBuildsFailedCount),
      securityBuildsFailedPath,
    };
    provide.projectFullPath = el.dataset.projectFullPath;
    provide.autoFixDocumentation = el.dataset.autoFixDocumentation;
    provide.autoFixMrsPath = el.dataset.autoFixMrsPath;
  } else if (dashboardType === DASHBOARD_TYPES.GROUP) {
    component = FirstClassGroupSecurityDashboard;
    props.groupFullPath = el.dataset.groupFullPath;
  } else if (dashboardType === DASHBOARD_TYPES.INSTANCE) {
    provide.instanceDashboardSettingsPath = el.dataset.instanceDashboardSettingsPath;
    component = FirstClassInstanceSecurityDashboard;
  }

  const router = createRouter();
  const store = createStore({ dashboardType });

  return new Vue({
    el,
    store,
    router,
    apolloProvider,
    provide: () => ({
      dashboardDocumentation: el.dataset.dashboardDocumentation,
      noVulnerabilitiesSvgPath: el.dataset.noVulnerabilitiesSvgPath,
      emptyStateSvgPath: el.dataset.emptyStateSvgPath,
      notEnabledScannersHelpPath: el.dataset.notEnabledScannersHelpPath,
      noPipelineRunScannersHelpPath: el.dataset.noPipelineRunScannersHelpPath,
      hasVulnerabilities: parseBoolean(el.dataset.hasVulnerabilities),
      ...provide,
    }),
    render(createElement) {
      return createElement(component, { props });
    },
  });
};
