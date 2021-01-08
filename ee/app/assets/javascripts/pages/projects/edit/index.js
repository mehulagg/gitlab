/* eslint-disable no-new */

import '~/pages/projects/edit';
import mountApprovals from 'ee/approvals/mount_project_settings';
import initProjectAdjournedDeleteButton from 'ee/projects/project_adjourned_delete_button';
import initMergeOptionSettings from 'ee/pages/projects/edit/merge_options';
import UsersSelect from '~/users_select';
import UserCallout from '~/user_callout';
import groupsSelect from '~/groups_select';

new UsersSelect();
groupsSelect();

new UserCallout({ className: 'js-mr-approval-callout' });

mountApprovals(document.getElementById('js-mr-approvals-settings'));

initProjectAdjournedDeleteButton();
initMergeOptionSettings();
