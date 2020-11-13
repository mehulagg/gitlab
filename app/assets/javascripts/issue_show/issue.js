import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { mapGetters } from 'vuex';
import createDefaultClient from '~/lib/graphql';
import { parseBoolean } from '~/lib/utils/common_utils';
import IssuableApp from './components/app.vue';
import HeaderActions from './components/header_actions.vue';

import createRouter from '~/design_management/router';
import desManApolloProvider from '~/design_management/graphql';

export function initIssuableApp(issuableData, store) {
  const router = createRouter(issuableData.issuePath);

  desManApolloProvider.clients.defaultClient.cache.writeData({
    data: {
      activeDiscussion: {
        __typename: 'ActiveDiscussion',
        id: null,
        source: null,
      },
    },
  });

  return new Vue({
    el: document.getElementById('js-issuable-app'),
    store,
    router,
    apolloProvider: desManApolloProvider,
    provide: {
      projectPath: `${issuableData.projectNamespace}/${issuableData.projectPath}`,
      issueIid: issuableData.iid,
    },
    computed: {
      ...mapGetters(['getNoteableData']),
    },
    render(createElement) {
      return createElement(IssuableApp, {
        props: {
          ...issuableData,
          isConfidential: this.getNoteableData?.confidential,
          isLocked: this.getNoteableData?.discussion_locked,
          issuableStatus: this.getNoteableData?.state,
        },
      });
    },
  });
}

export function initIssueHeaderActions(store) {
  const el = document.querySelector('.js-issue-header-actions');

  if (!el) {
    return undefined;
  }

  Vue.use(VueApollo);

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  return new Vue({
    el,
    apolloProvider,
    store,
    provide: {
      canCreateIssue: parseBoolean(el.dataset.canCreateIssue),
      canReopenIssue: parseBoolean(el.dataset.canReopenIssue),
      canReportSpam: parseBoolean(el.dataset.canReportSpam),
      canUpdateIssue: parseBoolean(el.dataset.canUpdateIssue),
      iid: el.dataset.iid,
      isIssueAuthor: parseBoolean(el.dataset.isIssueAuthor),
      issueType: el.dataset.issueType,
      newIssuePath: el.dataset.newIssuePath,
      projectPath: el.dataset.projectPath,
      reportAbusePath: el.dataset.reportAbusePath,
      submitAsSpamPath: el.dataset.submitAsSpamPath,
    },
    render: createElement => createElement(HeaderActions),
  });
}
