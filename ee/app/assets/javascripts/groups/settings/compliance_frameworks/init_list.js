import Vue from 'vue';
import VueApollo from 'vue-apollo';

import createDefaultClient from '~/lib/graphql';
import Form from './components/list.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient({}, { assumeImmutableResults: true }),
});

const createComplianceFrameworksListApp = (el) => {
  if (!el) {
    return false;
  }

  const { addFrameworkPath, canManageComplianceFrameworks, editFrameworkPath, emptyStateSvgPath, groupPath } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    render(createElement) {
      return createElement(Form, {
        props: {
          addFrameworkPath,
          canManageComplianceFrameworks,
          editFrameworkPath,
          emptyStateSvgPath,
          groupPath,
        },
      });
    },
  });
};

export { createComplianceFrameworksListApp };
