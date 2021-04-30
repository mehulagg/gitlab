import Vue from 'vue';
import DevopsScore from './components/devops_score.vue';

export default () => {
  const el = document.getElementById('js-devops-score');

  if (!el) return false;

  const { isEmpty, devopsScoreMetrics, devOpsReportDocsPath } = el.dataset;

  return new Vue({
    el,
    provide: {
      isEmpty,
      devopsScoreMetrics: JSON.parse(devopsScoreMetrics),
      devOpsReportDocsPath,
    },
    render(h) {
      return h(DevopsScore);
    },
  });
};
