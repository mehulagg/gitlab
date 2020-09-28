import Vue from 'vue';
import VueApollo from 'vue-apollo';

import createDefaultClient from '~/lib/graphql';

import TestCaseShowApp from './components/test_case_show_root.vue';

Vue.use(VueApollo);

export function initTestCaseShow({ mountPointSelector }) {
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
    },
    render: createElement => createElement(TestCaseShowApp),
  });
}
