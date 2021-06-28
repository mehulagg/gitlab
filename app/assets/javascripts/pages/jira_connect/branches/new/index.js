import Vue from 'vue';
import JiraConnectNewBranchApp from '~/jira_connect/pages/new_branch.vue';

export async function initJiraConnectNewBranch() {
  const el = document.querySelector('.js-jira-connect-create-branch');
  if (!el) {
    return null;
  }

  return new Vue({
    el,
    render(createElement) {
      return createElement(JiraConnectNewBranchApp);
    },
  });
}

initJiraConnectNewBranch();
