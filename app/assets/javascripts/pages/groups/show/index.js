import leaveByUrl from '~/namespaces/leave_by_url';
import initGroupDetails from '../shared/group_details';
import initInviteMembersTrigger from '~/invite_members/init_invite_members_trigger';
import initInviteMembersModal from '~/invite_members/init_invite_members_modal';

document.addEventListener('DOMContentLoaded', () => {
  leaveByUrl('group');
  initGroupDetails();
  initInviteMembersModal();
  initInviteMembersTrigger();
});
