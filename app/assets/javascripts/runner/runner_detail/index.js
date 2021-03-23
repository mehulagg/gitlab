import Vue from 'vue';
import RunnerDetailApp from './runner_detail_app.vue';

export const initRunnerDetail = (selector = '#js-runner-detail') => {
  const el = document.querySelector(selector);

  if (!el) {
    return;
  }

  const { runnerId } = el.dataset;

  // eslint-disable-next-line no-new
  new Vue({
    el,
    render(h) {
      return h(RunnerDetailApp, {
        props: {
          runnerId,
        },
      });
    },
  });
};
