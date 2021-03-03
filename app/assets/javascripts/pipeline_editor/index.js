import Vue from 'vue';

import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { resetServiceWorkersPublicPath } from '../lib/utils/webpack';
import { resolvers } from './graphql/resolvers';
import typeDefs from './graphql/typedefs.graphql';
import PipelineEditorApp from './pipeline_editor_app.vue';

export const initPipelineEditor = (selector = '#js-pipeline-editor') => {
  // Prevent issues loading syntax validation workers
  // Fixes https://gitlab.com/gitlab-org/gitlab/-/issues/297252
  // TODO Remove when https://gitlab.com/gitlab-org/gitlab/-/issues/321656 is resolved
  resetServiceWorkersPublicPath();

  const el = document.querySelector(selector);

  if (!el) {
    return null;
  }

  const {
    // Add to apollo cache as it can be updated by future queries
    commitSha,
    // Add to provide/inject API for static values
    ciConfigPath,
    defaultBranch,
    emptyStateIllustrationPath,
    lintHelpPagePath,
    newMergeRequestPath,
    projectFullPath,
    projectPath,
    projectNamespace,
    ymlHelpPagePath,
  } = el?.dataset;

  Vue.use(VueApollo);

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(resolvers, { typeDefs }),
  });

  apolloProvider.clients.defaultClient.cache.writeData({
    data: {
      commitSha,
    },
  });

  return new Vue({
    el,
    apolloProvider,
    provide: {
      ciConfigPath,
      defaultBranch,
      emptyStateIllustrationPath,
      lintHelpPagePath,
      newMergeRequestPath,
      projectFullPath,
      projectPath,
      projectNamespace,
      ymlHelpPagePath,
    },
    render(h) {
      return h(PipelineEditorApp);
    },
  });
};
