import Vue from 'vue';
import { getParameterValues } from '~/lib/utils/url_utility';
import LogViewer from './components/environment_logs.vue';
import store from './stores';

export default (props = {}) => {
  const el = document.getElementById('environment-logs');
  const [currentPodName] = getParameterValues('pod_name');

  // eslint-disable-next-line no-new
  new Vue({
    el,
    store,
    render(createElement) {
      let currentClusters = JSON.parse(el.dataset.currentClusters);
      delete el.dataset.clusters;

      return createElement(LogViewer, {
        props: {
          ...el.dataset,
          currentClusters,
          currentPodName,
          ...props,
        },
      });
    },
  });
};
