import Vue from 'vue';
import VueApollo from 'vue-apollo';

import createDefaultClient from '~/lib/graphql';
import CreateForm from './components/create_form.vue';
import EditForm from './components/edit_form.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient({}, { assumeImmutableResults: true }),
});

const createComplianceFrameworksFormApp = (el) => {
  if (!el) {
    return false;
  }

  const { groupEditPath, groupPath, graphqlFieldName = null, frameworkId: id = null } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    render(createElement) {
      let element = CreateForm;
      let props = { groupEditPath, groupPath };

      if (id) {
        element = EditForm;
        props = { ...props, graphqlFieldName, id };
      }

      return createElement(element, {
        props,
      });
    },
  });
};

export { createComplianceFrameworksFormApp };
