import Vue from 'vue';
import VueApollo from 'vue-apollo';

import createDefaultClient from '~/lib/graphql';
import Form from './components/list.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default () => {
  const el = document.querySelector('#js-compliance-framework-labels-list');

  if (!el) {
    return false;
  }

  const { emptyStateSvgPath, groupPath } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    render(createElement) {
      return createElement(Form, {
        props: {
          emptyStateSvgPath,
          groupPath,
        },
      });
    },
  });
};
