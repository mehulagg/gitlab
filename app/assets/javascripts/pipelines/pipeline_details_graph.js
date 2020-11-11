import Vue from 'vue';
import PipelineGraphNew from './components/graph/graph_component_new.vue';

const createPipelinesDetailApp = (selector) => {
  // Placeholder. See: https://gitlab.com/gitlab-org/gitlab/-/issues/223262
  // eslint-disable-next-line no-useless-return

  if (!document.querySelector(selector)) {
    return;
  }
  // eslint-disable-next-line no-new
  new Vue({
    el: selector,
    components: {
      PipelineGraphNew,
    },
    render(createElement) {
      return createElement('pipeline-graph-new')
    }
  });
};

export { createPipelinesDetailApp };
