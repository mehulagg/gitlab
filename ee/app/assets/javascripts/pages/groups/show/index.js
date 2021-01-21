import initGroupAnalytics from 'ee/analytics/group_analytics/group_analytics_bundle';
import leaveByUrl from '~/namespaces/leave_by_url';
import initGroupDetails from '~/pages/groups/shared/group_details';
import initVueAlerts from '~/vue_alerts';

leaveByUrl('group');
initGroupDetails();
initGroupAnalytics();
initVueAlerts();
