import Vue from 'vue';
import pathLastCommitQuery from 'shared_queries/repository/path_last_commit.query.graphql';
import permissionsQuery from 'shared_queries/repository/permissions.query.graphql';
import filesQuery from 'shared_queries/repository/files.query.graphql';
import { escapeFileUrl } from '../lib/utils/url_utility';
import createRouter from './router';
import App from './components/app.vue';
import Breadcrumbs from './components/breadcrumbs.vue';
import LastCommit from './components/last_commit.vue';
import TreeActionLink from './components/tree_action_link.vue';
import initWebIdeLink from '~/pages/projects/shared/web_ide_link';
import DirectoryDownloadLinks from './components/directory_download_links.vue';
import apolloProvider from './graphql';
import { setTitle } from './utils/title';
import { updateFormAction } from './utils/dom';
import { parseBoolean } from '../lib/utils/common_utils';
import { __ } from '../locale';

export default function setupVueRepositoryList() {
  const el = document.getElementById('js-tree-list');
  const { dataset } = el;
  const { projectPath, projectShortPath, ref, escapedRef, fullName } = dataset;
  const router = createRouter(projectPath, escapedRef);
  const pathRegex = /-\/tree\/[^/]+\/(.+$)/;
  const matches = window.location.href.match(pathRegex);

  const currentRoutePath = matches ? matches[1] : '';

  apolloProvider.clients.defaultClient.cache.writeData({
    data: {
      projectPath,
      projectShortPath,
      ref,
      escapedRef,
      commits: [],
    },
  });

  const initLastCommitApp = () =>
    new Vue({
      el: document.getElementById('js-last-commit'),
      router,
      apolloProvider,
      render(h) {
        return h(LastCommit, {
          props: {
            currentPath: this.$route.params.path,
          },
        });
      },
    });

  if (window.gl.startup_graphql_calls) {
    const query = window.gl.startup_graphql_calls.find(
      call => call.operationName === 'pathLastCommit',
    );
    query.fetchCall
      .then(res => res.json())
      .then(res => {
        apolloProvider.clients.defaultClient.writeQuery({
          query: pathLastCommitQuery,
          data: res.data,
          variables: {
            projectPath,
            ref,
            path: currentRoutePath,
          },
        });
      })
      .catch(() => {})
      .finally(() => initLastCommitApp());
  } else {
    initLastCommitApp();
  }

  router.afterEach(({ params: { path } }) => {
    setTitle(path, ref, fullName);
  });

  const breadcrumbEl = document.getElementById('js-repo-breadcrumb');

  if (breadcrumbEl) {
    const {
      canCollaborate,
      canEditTree,
      newBranchPath,
      newTagPath,
      newBlobPath,
      forkNewBlobPath,
      forkNewDirectoryPath,
      forkUploadBlobPath,
      uploadPath,
      newDirPath,
    } = breadcrumbEl.dataset;

    router.afterEach(({ params: { path = '/' } }) => {
      updateFormAction('.js-upload-blob-form', uploadPath, path);
      updateFormAction('.js-create-dir-form', newDirPath, path);
    });

    const initBreadcrumbsApp = () =>
      new Vue({
        el: breadcrumbEl,
        router,
        apolloProvider,
        render(h) {
          return h(Breadcrumbs, {
            props: {
              currentPath: this.$route.params.path,
              canCollaborate: parseBoolean(canCollaborate),
              canEditTree: parseBoolean(canEditTree),
              newBranchPath,
              newTagPath,
              newBlobPath,
              forkNewBlobPath,
              forkNewDirectoryPath,
              forkUploadBlobPath,
            },
          });
        },
      });

    if (window.gl.startup_graphql_calls) {
      const query = window.gl.startup_graphql_calls.find(
        call => call.operationName === 'getPermissions',
      );
      query.fetchCall
        .then(res => res.json())
        .then(res => {
          apolloProvider.clients.defaultClient.writeQuery({
            query: permissionsQuery,
            data: res.data,
            variables: {
              projectPath,
            },
          });
        })
        .catch(() => {})
        .finally(() => initBreadcrumbsApp());
    } else {
      initBreadcrumbsApp();
    }
  }

  const treeHistoryLinkEl = document.getElementById('js-tree-history-link');
  const { historyLink } = treeHistoryLinkEl.dataset;

  // eslint-disable-next-line no-new
  new Vue({
    el: treeHistoryLinkEl,
    router,
    render(h) {
      return h(TreeActionLink, {
        props: {
          path: `${historyLink}/${
            this.$route.params.path ? escapeFileUrl(this.$route.params.path) : ''
          }`,
          text: __('History'),
        },
      });
    },
  });

  initWebIdeLink({ el: document.getElementById('js-tree-web-ide-link'), router });

  const directoryDownloadLinks = document.getElementById('js-directory-downloads');

  if (directoryDownloadLinks) {
    // eslint-disable-next-line no-new
    new Vue({
      el: directoryDownloadLinks,
      router,
      render(h) {
        const currentPath = this.$route.params.path || '/';

        if (currentPath !== '/') {
          return h(DirectoryDownloadLinks, {
            props: {
              currentPath: currentPath.replace(/^\//, ''),
              links: JSON.parse(directoryDownloadLinks.dataset.links),
            },
          });
        }

        return null;
      },
    });
  }

  const initTreeListApp = () =>
    new Vue({
      el,
      router,
      apolloProvider,
      render(h) {
        return h(App);
      },
    });

  if (window.gl.startup_graphql_calls) {
    const query = window.gl.startup_graphql_calls.find(call => call.operationName === 'getFiles');
    query.fetchCall
      .then(res => res.json())
      .then(res => {
        apolloProvider.clients.defaultClient.writeQuery({
          query: filesQuery,
          data: res.data,
          variables: {
            projectPath,
            ref,
            path: currentRoutePath || '/',
            nextPageCursor: '',
            pageSize: 100,
          },
        });
      })
      .catch(() => {})
      .finally(() => initTreeListApp());
  } else {
    initTreeListApp();
  }

  return { router, data: dataset };
}
