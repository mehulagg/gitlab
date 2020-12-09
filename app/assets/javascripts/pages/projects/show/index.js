/* eslint-disable no-new */
import initTree from 'ee_else_ce/repository';
import $ from 'jquery';
import BlobFileDropzone from '../../../blob/blob_file_dropzone';
import NewCommitForm from '../../../new_commit_form';
import { disableButtonIfEmptyField } from '~/lib/utils/common_utils';
import ShortcutsNavigation from '~/behaviors/shortcuts/shortcuts_navigation';
import NotificationsForm from '~/notifications_form';
import UserCallout from '~/user_callout';
import BlobViewer from '~/blob/viewer/index';
import Activities from '~/activities';
import initReadMore from '~/read_more';
import leaveByUrl from '~/namespaces/leave_by_url';
import Star from '../../../star';
import notificationsDropdown from '../../../notifications_dropdown';
import { showLearnGitLabProjectPopover } from '~/onboarding_issues';
import initInviteMembersTrigger from '~/invite_members/init_invite_members_trigger';
import initInviteMembersModal from '~/invite_members/init_invite_members_modal';

initReadMore();
new Star(); // eslint-disable-line no-new

new NotificationsForm(); // eslint-disable-line no-new
// eslint-disable-next-line no-new
new UserCallout({
  setCalloutPerProject: false,
  className: 'js-autodevops-banner',
});

// Project show page loads different overview content based on user preferences
const treeSlider = document.getElementById('js-tree-list');
if (treeSlider) {
  const uploadBlobForm = $('.js-upload-blob-form');

  if (uploadBlobForm.length) {
    const method = uploadBlobForm.data('method');

    new BlobFileDropzone(uploadBlobForm, method);
    new NewCommitForm(uploadBlobForm);

    disableButtonIfEmptyField(uploadBlobForm.find('.js-commit-message'), '.btn-upload-file');
  }
  initTree();
}

if (document.querySelector('.blob-viewer')) {
  new BlobViewer(); // eslint-disable-line no-new
}

if (document.querySelector('.project-show-activity')) {
  new Activities(); // eslint-disable-line no-new
}

leaveByUrl('project');

showLearnGitLabProjectPopover();

notificationsDropdown();
new ShortcutsNavigation(); // eslint-disable-line no-new

initInviteMembersTrigger();
initInviteMembersModal();
