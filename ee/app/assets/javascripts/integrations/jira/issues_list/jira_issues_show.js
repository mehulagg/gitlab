import Vue from 'vue';

import JiraIssueApp from './components/jira_issues_show_root.vue';

export default function initJiraIssueShow({ mountPointSelector }) {
  const mountPointEl = document.querySelector(mountPointSelector);

  if (!mountPointEl) {
    return null;
  }

  return new Vue({
    el: mountPointEl,
    provide: {},
    render: (createElement) => createElement(JiraIssueApp),
  });
}
