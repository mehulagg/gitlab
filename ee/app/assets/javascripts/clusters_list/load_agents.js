import Agents from './components/agents.vue';
import createDefaultClient from '~/lib/graphql';

export default (Vue, VueApollo) => {
  const agentsList = document.querySelector('#js-cluster-agents-list');

  if (!agentsList) {
    return null;
  }

  const defaultClient = createDefaultClient();

  defaultClient.cache.writeData({
    /* eslint-disable @gitlab/require-i18n-strings */
    data: {
      project: {
        __typename: 'Project',
        clusterAgents: {
          __typename: 'ClusterAgents',
          nodes: [],
        },

        repository: {
          __typename: 'Repository',
          tree: {
            __typename: 'Tree',
            trees: {
              __typename: 'Trees',
              nodes: [],
            },
          },
        },
      },
    },
  });

  return new Vue({
    el: '#js-cluster-agents-list',
    apolloProvider: new VueApollo({ defaultClient }),
    provide: {
      emptyStateImage: agentsList.dataset.emptyStateImage,
      defaultBranchName: agentsList.dataset.defaultBranchName,
      projectPath: agentsList.dataset.projectPath,
    },
    render(createElement) {
      return createElement(Agents);
    },
  });
};
