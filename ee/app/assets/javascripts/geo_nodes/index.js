import Vue from 'vue';
import { GlToast } from '@gitlab/ui';

import Translate from '~/vue_shared/translate';
import { parseBoolean, convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

import GeoNodesStore from './store/geo_nodes_store';
import GeoNodesService from './service/geo_nodes_service';

import geoNodesApp from './components/app.vue';

Vue.use(Translate);
Vue.use(GlToast);

export default () => {
  const el = document.getElementById('js-geo-nodes');

  if (!el) {
    return false;
  }

  return new Vue({
    el,
    components: {
      geoNodesApp,
    },
    data() {
      const { dataset } = this.$options.el;
      const { primaryVersion, primaryRevision, geoTroubleshootingHelpPath } = dataset;
      const replicableTypes = convertObjectPropsToCamelCase(JSON.parse(dataset.replicableTypes), {
        deep: true,
      });
      const nodeActionsAllowed = parseBoolean(dataset.nodeActionsAllowed);
      const nodeEditAllowed = parseBoolean(dataset.nodeEditAllowed);
      const store = new GeoNodesStore(primaryVersion, primaryRevision, replicableTypes);
      const service = new GeoNodesService();

      return {
        store,
        service,
        nodeActionsAllowed,
        nodeEditAllowed,
        geoTroubleshootingHelpPath,
      };
    },
    render(createElement) {
      return createElement('geo-nodes-app', {
        props: {
          store: this.store,
          service: this.service,
          nodeActionsAllowed: this.nodeActionsAllowed,
          nodeEditAllowed: this.nodeEditAllowed,
          geoTroubleshootingHelpPath: this.geoTroubleshootingHelpPath,
        },
      });
    },
  });
};
