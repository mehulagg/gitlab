import Vue from 'vue';
import VueApollo from 'vue-apollo';

import createDefaultClient from '~/lib/graphql';
import { parseBoolean } from '~/lib/utils/common_utils';

import EpicShowApp from './components/epic_show_root.vue';

Vue.use(VueApollo);

export default function initEpicShow({ mountPointSelector }) {
  const el = document.querySelector(mountPointSelector);

  if (!el) {
    return null;
  }

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  return new Vue({
    el,
    apolloProvider,
    provide: {
      ...el.dataset,
      canEditEpic: parseBoolean(el.dataset.canEditEpic),
      lockVersion: parseInt(el.dataset.lockVersion, 10),
    },
    render: (createElement) => createElement(EpicShowApp),
  });
}
