import Vue from 'vue';
import PipelineQuotaAlert from './components/pipeline_quota_alert.vue';

export default () => {
  const el = document.getElementById('pipeline-schedules-quota');

  if (!el) {
    return;
  }

  const { docsUrl } = el.dataset;

  return new Vue({
    el,
    provide: {
      docsUrl,
    },
    render(createElement) {
      return createElement(PipelineQuotaAlert);
    },
  });
};
