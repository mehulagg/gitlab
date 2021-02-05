import Vue from 'vue';

import JiraIssuesShowApp from './components/jira_issues_show_root.vue';

export default function initJiraIssueShow({ mountPointSelector }) {
  const mountPointEl = document.querySelector(mountPointSelector);

  if (!mountPointEl) {
    return null;
  }

  const { issuesShowPath } = mountPointEl.dataset;

  return new Vue({
    el: mountPointEl,
    provide: {
      issuesShowPath,
    },
    render: (createElement) => createElement(JiraIssuesShowApp),
  });
}
