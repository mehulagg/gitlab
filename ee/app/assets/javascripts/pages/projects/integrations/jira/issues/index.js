import initJiraIssuesList from 'ee/integrations/jira/issues_list/jira_issues_list_bundle';
import initIssuablesList from '~/issues_list';

document.addEventListener('DOMContentLoaded', () => {
  if (gon.features.jiraIssuesList) {
    initJiraIssuesList({
      mountPointSelector: '#js-jira-issues-list',
    });
  } else {
    initIssuablesList();
  }
});
