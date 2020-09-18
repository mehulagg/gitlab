import Clusters from './components/clusters.vue';
import { createStore } from './store';

export default Vue => {
  const clustersList = document.querySelector('#js-clusters-list-app');

  if (!clustersList) {
    return null;
  }

  return new Vue({
    el: '#js-clusters-list-app',
    store: createStore(clustersList.dataset),
    render(createElement) {
      return createElement(Clusters);
    },
  });
};
