import Vue from 'vue';
import apolloProvider from './graphql/provider';
import OnDemandScansForm from './components/on_demand_scans_form.vue';

export default () => {
  const el = document.querySelector('#js-on-demand-scans-app');
  if (!el) {
    return null;
  }

  const {
    dastSiteValidationDocsPath,
    projectPath,
    defaultBranch,
    scannerProfilesLibraryPath,
    siteProfilesLibraryPath,
    newSiteProfilePath,
    newScannerProfilePath,
    helpPagePath,
    dastScan,
  } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    provide: {
      scannerProfilesLibraryPath,
      siteProfilesLibraryPath,
      newScannerProfilePath,
      newSiteProfilePath,
      dastSiteValidationDocsPath,
    },
    render(h) {
      return h(OnDemandScansForm, {
        props: {
          helpPagePath,
          projectPath,
          defaultBranch,
          dastScan: dastScan ? JSON.parse(dastScan) : null,
        },
      });
    },
  });
};
