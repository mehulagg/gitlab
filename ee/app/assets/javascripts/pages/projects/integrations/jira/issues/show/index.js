import initJiraIssueShow from 'ee/integrations/jira/issues_show/jira_issues_show_bundle';

document.addEventListener('DOMContentLoaded', () => {
  initJiraIssueShow({ mountPointSelector: '.js-jira-issues-show-app' });
});
