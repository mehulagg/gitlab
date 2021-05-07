import initContributionAanalyticsCharts from 'ee/analytics/contribution_analytics/contribution_analytics_bundle';
import initGroupMemberContributions from 'ee/group_member_contributions';

const dataEl = document.getElementById('js-analytics-data');
if (dataEl) {
  initContributionAanalyticsCharts(dataEl);
  initGroupMemberContributions();
}
