import initJiraIssueShow from 'ee/integrations/jira/issues_list/jira_issues_show';

document.addEventListener('DOMContentLoaded', () => {
  initJiraIssueShow({ mountPointSelector: '#js-jira-issues-show-app' });
});
