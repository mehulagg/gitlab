import Vue from 'vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import Translate from '~/vue_shared/translate';
import GeoNodesApp from './components/app.vue';
import createStore from './store';

Vue.use(Translate);

export const initGeoNodes = () => {
  const el = document.getElementById('js-geo-nodes');

  if (!el) {
    return false;
  }

  const { primaryVersion, primaryRevision, newNodeUrl, geoNodesEmptyStateSvg } = el.dataset;
  let { replicableTypes } = el.dataset;

  replicableTypes = convertObjectPropsToCamelCase(JSON.parse(replicableTypes), { deep: true });

  return new Vue({
    el,
    store: createStore({ primaryVersion, primaryRevision, replicableTypes }),
    render(createElement) {
      return createElement(GeoNodesApp, {
        props: {
          newNodeUrl,
          geoNodesEmptyStateSvg,
        },
      });
    },
  });
};
