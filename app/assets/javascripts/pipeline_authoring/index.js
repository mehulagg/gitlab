import Vue from 'vue';
import PipelinesAuthoringApp from './pipeline_authoring_app.vue';

export const initPipelineAuthoring = (selector = '#js-pipeline-authoring') => {
  const el = document.querySelector(selector);

  return new Vue({
    el,
    render(h) {
      return h(PipelinesAuthoringApp);
    },
  });
};
