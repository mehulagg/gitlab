import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { DASHBOARD_TYPES } from 'ee/security_dashboard/store/constants';
import FirstClassProjectSecurityDashboard from './components/first_class_project_security_dashboard.vue';
import FirstClassGroupSecurityDashboard from './components/first_class_group_security_dashboard.vue';
import createStore from './store';
import createRouter from './store/router';
import projectsPlugin from './store/plugins/projects';
import syncWithRouter from './store/plugins/sync_with_router';

const isRequired = message => {
  throw new Error(message);
};

export default (
  /* eslint-disable @gitlab/require-i18n-strings */
  el = isRequired('No element was passed to the security dashboard initializer'),
  dashboardType = isRequired('No dashboard type was passed to the security dashboard initializer'),
  /* eslint-enable @gitlab/require-i18n-strings */
) => {
  Vue.use(VueApollo);

  const resolvers = {
    Mutation: {
      removeDismissedVulnerabilities(_, { ids }, { cache }) {
        console.log('Hello!')
      }
    }
  }

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(resolvers),
  });
  const {
    dashboardDocumentation,
    emptyStateSvgPath,
    hasPipelineData,
    securityDashboardHelpPath,
  } = el.dataset;
  const props = {
    emptyStateSvgPath,
    dashboardDocumentation,
    hasPipelineData: Boolean(hasPipelineData),
    securityDashboardHelpPath,
  };
  let component;

  if (dashboardType === DASHBOARD_TYPES.PROJECT) {
    component = FirstClassProjectSecurityDashboard;
    props.projectFullPath = el.dataset.projectFullPath;
  } else if (dashboardType === DASHBOARD_TYPES.GROUP) {
    component = FirstClassGroupSecurityDashboard;
    props.groupFullPath = el.dataset.groupFullPath;
    props.vulnerableProjectsEndpoint = el.dataset.vulnerableProjectsEndpoint;
  }

  const router = createRouter();
  const store = createStore({ dashboardType, plugins: [projectsPlugin, syncWithRouter(router)] });

  return new Vue({
    el,
    store,
    router,
    apolloProvider,
    render(createElement) {
      return createElement(component, { props });
    },
  });
};
