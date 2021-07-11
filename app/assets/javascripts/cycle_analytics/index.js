import Vue from 'vue';
import Translate from '../vue_shared/translate';
import CycleAnalytics from './components/base.vue';
import createStore from './store';

Vue.use(Translate);

export default () => {
  const store = createStore();
  const el = document.querySelector('#js-cycle-analytics');
  console.log('el.dataset', el.dataset);
  const {
    noAccessSvgPath,
    noDataSvgPath,
    requestPath,
    fullPath,
    projectId,
    parentId,
    parentPath,
  } = el.dataset;
  console.log('projectId', parseInt(projectId, 10));
  console.log('parentId', parseInt(parentId, 10));
  console.log('parentPath', parentPath);

  store.dispatch('initializeVsa', {
    parentId: parseInt(parentId, 10),
    projectId: parseInt(projectId, 10),
    parentPath,
    requestPath,
    fullPath,
  });

  // eslint-disable-next-line no-new
  new Vue({
    el,
    name: 'CycleAnalytics',
    store,
    render: (createElement) =>
      createElement(CycleAnalytics, {
        props: {
          noDataSvgPath,
          noAccessSvgPath,
          fullPath,
        },
      }),
  });
};
