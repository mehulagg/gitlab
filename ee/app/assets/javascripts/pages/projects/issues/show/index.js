import trackShowInviteMemberLink from 'ee/projects/track_invite_members';
import initSidebarBundle from 'ee/sidebar/sidebar_bundle';

import initShow from '~/pages/projects/issues/show';
import initRelatedIssues from '~/related_issues';
import UserCallout from '~/user_callout';

initShow();
initSidebarBundle();
initRelatedIssues();

// eslint-disable-next-line no-new
new UserCallout({ className: 'js-epics-sidebar-callout' });
// eslint-disable-next-line no-new
new UserCallout({ className: 'js-weight-sidebar-callout' });

const assigneeDropdown = document.querySelector('.js-sidebar-assignee-dropdown');

if (assigneeDropdown) trackShowInviteMemberLink(assigneeDropdown);
