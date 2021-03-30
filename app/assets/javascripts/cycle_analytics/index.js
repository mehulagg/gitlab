import Vue from 'vue';
import Translate from '../vue_shared/translate';
import CycleAnalytics from './components/base.vue';
import createStore from './store';

Vue.use(Translate);

export default () => {
  const store = createStore();
  const el = document.querySelector('#js-cycle-analytics');
  console.log('dataset', el.dataset);
  const {
    noAccessSvgPath,
    noDataSvgPath,
    groupId,
    groupPath,
    labelsPath,
    milestonesPath,
    requestPath,
    fullPath,
    createdBefore,
    createdAfter,
    projectId,
  } = el.dataset;

  console.log('index', requestPath, fullPath, groupId, groupPath);

  store.dispatch('initializeVsa', {
    id: parseInt(projectId, 10),
    currentGroup: { id: parseInt(groupId, 10), path: groupPath },
    endpoints: {
      requestPath,
      labelsPath,
      milestonesPath,
      fullPath,
    },
    createdBefore: new Date(createdBefore),
    createdAfter: new Date(createdAfter),
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
