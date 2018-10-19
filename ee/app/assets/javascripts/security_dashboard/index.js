import Vue from 'vue';
import GroupSecurityDashboardApp from './components/app.vue';
import store from './store';

export default () => {
  const el = document.getElementById('js-group-security-dashboard');

  return new Vue({
    el,
    store,
    components: {
      GroupSecurityDashboardApp,
    },
    render(createElement) {
      return createElement('group-security-dashboard-app', {
        props: {
          dashboardDocumentation: el.dataset.dashboardDocumentation,
          errorStateSvgPath: el.dataset.errorStateSvgPath,
          emptyStateSvgPath: el.dataset.emptyStateSvgPath,
          vulnerabilitiesEndpoint: el.dataset.vulnerabilitiesEndpoint,
          vulnerabilitiesCountEndpoint: el.dataset.vulnerabilitiesSummaryEndpoint,
        },
      });
    },
  });
};
