import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import createStore from './store';
import GeoNodeFormApp from './components/app.vue';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('js-geo-node-form');

  return new Vue({
    el,
    store: createStore(),
    components: {
      GeoNodeFormApp,
    },
    render(createElement) {
      const {
        dataset: { selectiveSyncTypes, syncShardsOptions, nodeData },
      } = this.$options.el;

      let node;
      if (nodeData) {
        node = JSON.parse(nodeData);
        node = convertObjectPropsToCamelCase(node, { deep: true });
      }

      return createElement('geo-node-form-app', {
        props: {
          selectiveSyncTypes: JSON.parse(selectiveSyncTypes),
          syncShardsOptions: JSON.parse(syncShardsOptions),
          node,
        },
      });
    },
  });
};
