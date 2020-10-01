import initSidebarBundle from 'ee/sidebar/sidebar_bundle';
import trackShowInviteMemberLink from 'ee/projects/track_invite_members';
import initInviteMemberTrigger from 'ee/invite_member/init_invite_member_trigger';
import initInviteMemberModal from 'ee/invite_member/init_invite_member_modal';
import initRelatedIssues from '~/related_issues';
import initShow from '~/pages/projects/issues/show';
import UserCallout from '~/user_callout';

document.addEventListener('DOMContentLoaded', () => {
  initShow();
  if (gon.features && !gon.features.vueIssuableSidebar) {
    initSidebarBundle();
  }
  initRelatedIssues();

  // eslint-disable-next-line no-new
  new UserCallout({ className: 'js-epics-sidebar-callout' });
  // eslint-disable-next-line no-new
  new UserCallout({ className: 'js-weight-sidebar-callout' });

  const assigneeDropdown = document.querySelector('.js-sidebar-assignee-dropdown');

  if (assigneeDropdown) trackShowInviteMemberLink(assigneeDropdown);

  initInviteMemberModal();
  initInviteMemberTrigger();
});
