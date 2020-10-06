import Vue from 'vue';
import issuableApp from './components/app.vue';
import Header from './components/header.vue';
import { parseBoolean } from '~/lib/utils/common_utils';

export function initIssuableApp(issuableData) {
  return new Vue({
    el: document.getElementById('js-issuable-app'),
    components: {
      issuableApp,
    },
    render(createElement) {
      return createElement('issuable-app', {
        props: issuableData,
      });
    },
  });
}

export function initIssueHeader(store) {
  const el = document.querySelector('.js-issue-header');

  if (!el) {
    return undefined;
  }

  return new Vue({
    el,
    store,
    render: createElement =>
      createElement(Header, {
        props: {
          canCreateIssue: parseBoolean(el.dataset.canCreateIssue),
          canReopenIssue: parseBoolean(el.dataset.canReopenIssue),
          canReportSpam: parseBoolean(el.dataset.canReportSpam),
          canUpdateIssue: parseBoolean(el.dataset.canUpdateIssue),
          isIssueAuthor: parseBoolean(el.dataset.isIssueAuthor),
          closeIssuePath: el.dataset.closeIssuePath,
          newIssuePath: el.dataset.newIssuePath,
          reopenIssuePath: el.dataset.reopenIssuePath,
          reportAbusePath: el.dataset.reportAbusePath,
          submitAsSpamPath: el.dataset.submitAsSpamPath,
        },
      }),
  });
}
