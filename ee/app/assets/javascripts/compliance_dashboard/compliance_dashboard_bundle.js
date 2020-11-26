import Vue from 'vue';
import ComplianceDashboard from './components/dashboard.vue';
import { parseBoolean } from '~/lib/utils/common_utils';

export default () => {
  const el = document.getElementById('js-compliance-dashboard');

  const { mergeRequests, emptyStateSvgPath, isLastPage, mergeCommitsCsvExportPath } = el.dataset;

  return new Vue({
    el,
    render: createElement =>
      createElement(ComplianceDashboard, {
        props: {
          mergeRequests: JSON.parse(mergeRequests),
          isLastPage: parseBoolean(isLastPage),
          emptyStateSvgPath,
          mergeCommitsCsvExportPath,
        },
      }),
  });
};
