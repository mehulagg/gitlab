import Vue from 'vue';
import apolloProvider from './graphql/provider';
import OnDemandScansApp from './components/on_demand_scans_app.vue';

export default () => {
  const el = document.querySelector('#js-on-demand-scans-app');
  if (!el) {
    return null;
  }

  const {
    helpPagePath,
    emptyStateSvgPath,
    projectPath,
    defaultBranch,
    profilesLibraryPath,
    newSiteProfilePath,
  } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    render(h) {
      return h(OnDemandScansApp, {
        props: {
          helpPagePath,
          emptyStateSvgPath,
          projectPath,
          defaultBranch,
          profilesLibraryPath,
          newSiteProfilePath,
        },
      });
    },
  });
};
