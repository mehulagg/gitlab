import Vue from 'vue';
import createRouter from './router';
import App from './components/app.vue';
import apolloProvider from './graphql';

export const createDesignManagement = ({
  iid: issueIid,
  projectPath,
  issuePath,
  projectNamespace,
}) => {
  // NOTE: Design Management is not currently supported at the group level
  // currently we are just pulling in the project path for the Graphql call
  // but when we support groups we will need to add group path support for
  // design management in issuables_helper.rb

  const router = createRouter(issuePath);

  apolloProvider.clients.defaultClient.cache.writeData({
    data: {
      activeDiscussion: {
        __typename: 'ActiveDiscussion',
        id: null,
        source: null,
      },
    },
  });

  return {
    router,
    apolloProvider,
    provide: {
      projectPath: `${projectNamespace}/${projectPath}`,
      issueIid,
    },
  };
};

export default () => {
  const el = document.querySelector('.js-design-management');
  const { issueIid, projectPath, issuePath } = el.dataset;
  const router = createRouter(issuePath);

  apolloProvider.clients.defaultClient.cache.writeData({
    data: {
      activeDiscussion: {
        __typename: 'ActiveDiscussion',
        id: null,
        source: null,
      },
    },
  });

  return new Vue({
    el,
    router,
    apolloProvider,
    provide: {
      projectPath,
      issueIid,
    },
    render(createElement) {
      return createElement(App);
    },
  });
};
