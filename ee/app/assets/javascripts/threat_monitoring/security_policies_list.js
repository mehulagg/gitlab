import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import SecurityPoliciesListApp from './components/security_policies_list/app.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default () => {
  const el = document.querySelector('#js-security-policies-list');
  const { documentationPath, assignedPolicyProject, selectProjectPath } = el.dataset;

  return new Vue({
    apolloProvider,
    el,
    provide: {
      documentationPath,
      selectProjectPath,
    },
    render(createElement) {
      return createElement(SecurityPoliciesListApp, {
        props: {
          assignedPolicyProject: JSON.parse(assignedPolicyProject),
        },
      });
    },
  });
};
