import createDefaultClient from '~/lib/graphql';
import Agents from './components/agents.vue';

export default (Vue, VueApollo) => {
  const el = document.querySelector('#js-cluster-agents-list');

  if (!el) {
    return null;
  }

  const defaultClient = createDefaultClient();

  const {
    emptyStateImage,
    defaultBranchName,
    projectPath,
    agentDocsUrl,
    installDocsUrl,
    getStartedDocsUrl,
    integrationDocsUrl,
  } = el.dataset;

  return new Vue({
    el,
    apolloProvider: new VueApollo({ defaultClient }),
    provide: {
      emptyStateImage,
      defaultBranchName,
      projectPath,
      agentDocsUrl,
      installDocsUrl,
      getStartedDocsUrl,
      integrationDocsUrl,
    },
    render: (createElement) => createElement(Agents),
  });
};
