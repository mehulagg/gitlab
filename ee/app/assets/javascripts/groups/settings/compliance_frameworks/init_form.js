import Vue from 'vue';
import VueApollo from 'vue-apollo';

import CreateForm from './components/create_form.vue';
import EditForm from './components/edit_form.vue';
import createDefaultClient, { fetchPolicies } from '~/lib/graphql';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient({}, { fetchPolicy: fetchPolicies.NO_CACHE }),
});

const createComplianceFrameworksFormApp = (el) => {
  if (!el) {
    return false;
  }

  const { groupEditPath, groupPath, frameworkId: id = null } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    render(createElement) {
      let element = CreateForm;
      let props = { groupEditPath, groupPath };

      if (id) {
        element = EditForm;
        props = { ...props, id };
      }

      return createElement(element, {
        props,
      });
    },
  });
};

export { createComplianceFrameworksFormApp };
