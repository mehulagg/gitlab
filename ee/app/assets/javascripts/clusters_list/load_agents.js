import Agents from './components/agents.vue';
import createDefaultClient from '~/lib/graphql';

export default (Vue, VueApollo) => {
  const el = document.querySelector('#js-cluster-agents-list');

  if (!el) {
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

  const { emptyStateImage, defaultBranchName, projectPath } = el.dataset;

  return new Vue({
    el,
    apolloProvider: new VueApollo({ defaultClient }),
    render(createElement) {
      return createElement(Agents, {
        props: {
          emptyStateImage,
          defaultBranchName,
          projectPath,
        },
      });
    },
  });
};
