import Vue from 'vue';
import App from './components/app.vue';

const parseProps = dataset => {
  const { isGitlabConnected, jiraConnectUsersPath } = dataset;

  return {
    jiraConnectUsersPath,
    isGitlabConnected: JSON.parse(isGitlabConnected),
  };
};

function initJiraConnect() {
  const el = document.querySelector('.js-jira-connect-app');
  if (!el) return null;

  return new Vue({
    el,
    render(createElement) {
      return createElement(App, {
        props: parseProps(el.dataset),
      });
    },
  });
}

document.addEventListener('DOMContentLoaded', initJiraConnect);
