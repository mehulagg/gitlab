import initSidebarBundle from 'ee/sidebar/sidebar_bundle';
import trackShowInviteMemberLink from 'ee/projects/track_invite_members';
import initTestCaseShow from 'ee/test_case_show/test_case_show_bundle';

import { parseIssuableData } from '~/issue_show/utils/parse_data';
import initRelatedIssues from '~/related_issues';
import initShow from '~/pages/projects/issues/show';
import UserCallout from '~/user_callout';

import { IssuableType } from '~/issuable_show/constants';

const { issueType } = parseIssuableData();

initShow();

if (issueType === IssuableType.TestCase) {
  initTestCaseShow({
    mountPointSelector: '#js-issuable-app',
  });
}

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
