import { s__, __ } from '~/locale';

export const OPEN_REVERT_MODAL = 'openRevertModal';
export const REVERT_MODAL_ID = 'revert-commit-modal';
export const REVERT_LINK_TEST_ID = 'revert-commit-link';
export const OPEN_CHERRY_PICK_MODAL = 'openCherryPickModal';
export const CHERRY_PICK_MODAL_ID = 'cherry-pick-commit-modal';
export const CHERRY_PICK_LINK_TEST_ID = 'cherry-pick-commit-link';

export const I18N_MODAL = {
  startMergeRequest: s__('ChangeTypeAction|Start a %{newMergeRequest} with these changes'),
  existingBranch: s__(
    'ChangeTypeAction|Your changes will be committed to %{branchName} because a merge request is open.',
  ),
  branchInFork: s__(
    'ChangeTypeAction|A new branch will be created in your fork and a new merge request will be started.',
  ),
  newMergeRequest: __('new merge request'),
  actionCancelText: __('Cancel'),
};

export const I18N_REVERT_MODAL = {
  branchLabel: s__('ChangeTypeAction|Revert in branch'),
  actionPrimaryText: s__('ChangeTypeAction|Revert'),
};

export const I18N_CHERRY_PICK_MODAL = {
  branchLabel: s__('ChangeTypeAction|Pick into branch'),
  projectLabel: s__('ChangeTypeAction|Pick into project'),
  actionPrimaryText: s__('ChangeTypeAction|Cherry-pick'),
};

export const PREPENDED_MODAL_TEXT = s__(
  'ChangeTypeAction|This will create a new commit in order to revert the existing changes.',
);

export const I18N_DROPDOWN = {
  noResultsMessage: __('No matching results'),
  branchHeaderTitle: s__('ChangeTypeAction|Switch branch'),
  branchSearchPlaceholder: s__('ChangeTypeAction|Search branches'),  
  projectHeaderTitle: s__('ChangeTypeAction|Switch project'),
  projectSearchPlaceholder: s__('ChangeTypeAction|Search project'),
};

export const PROJECT_BRANCHES_ERROR = __('Something went wrong while fetching branches');
export const PROJECTS_FETCH_ERROR = __('Something went wrong while fetching projects');
