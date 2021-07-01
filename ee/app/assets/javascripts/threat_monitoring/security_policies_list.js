import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import createDefaultClient from '~/lib/graphql';
import SecurityPolicyProjectSelector from './components/security_policy_project_selector.vue';

const GRAPHQL_TYPE = 'Project';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default () => {
  const el = document.querySelector('#js-security-policies-list');
  const { assignedPolicyProject, documentationPath, projectPath } = el.dataset;

  const policyProject = JSON.parse(assignedPolicyProject);
  policyProject.id = convertToGraphQLId(GRAPHQL_TYPE, policyProject.id);

  return new Vue({
    apolloProvider,
    el,
    provide: {
      documentationPath,
      projectPath,
    },
    render(createElement) {
      return createElement(SecurityPolicyProjectSelector, {
        props: {
          assignedPolicyProject: policyProject,
        },
      });
    },
  });
};
