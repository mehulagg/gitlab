import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import SecurityPolicyProjectSelector from './components/security_policy_project_selector.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default () => {
  const el = document.querySelector('#js-security-policies-list');
  const { assignedPolicyProject, documentationPath, projectPath, selectProjectPath } = el.dataset;

  return new Vue({
    apolloProvider,
    el,
    provide: {
      documentationPath,
      projectPath,
      selectProjectPath,
    },
    render(createElement) {
      return createElement(SecurityPolicyProjectSelector, {
        props: {
          assignedPolicyProject: JSON.parse(assignedPolicyProject),
        },
      });
    },
  });
};
