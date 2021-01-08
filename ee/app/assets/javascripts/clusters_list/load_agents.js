import Agents from './components/agents.vue';
import createDefaultClient from '~/lib/graphql';

export default (Vue, VueApollo) => {
  const el = document.querySelector('#js-cluster-agents-list');

  if (!el) {
    return null;
  }

  const defaultClient = createDefaultClient();

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
