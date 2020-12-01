import initGroupAnalytics from 'ee/analytics/group_analytics/group_analytics_bundle';
import leaveByUrl from '~/namespaces/leave_by_url';
import initGroupDetails from '~/pages/groups/shared/group_details';
import initVueAlerts from '~/vue_alerts';
import initInviteMembersTrigger from '~/invite_members/init_invite_members_trigger';
import initInviteMembersModal from '~/invite_members/init_invite_members_modal';

leaveByUrl('group');
initGroupDetails();
initGroupAnalytics();
initVueAlerts();
initInviteMembersModal();
initInviteMembersTrigger();
