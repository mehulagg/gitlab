import Vue from 'vue';
import CommitOptionsDropdown from './components/commit_options_dropdown.vue';

export default function initCommitOptionsDropdown() {
  const el = document.querySelector('#js-commit-options-dropdown');

  if (!el) {
    return false;
  }

  const {
    newProjectTagPath,
    emailPatchesPath,
    plainDiffPath,
    canRevert,
    canCherryPick,
    canTag,
    canEmailPatches,
  } = el.dataset;

  return new Vue({
    el,
    provide: { newProjectTagPath, emailPatchesPath, plainDiffPath },
    render: (createElement) =>
      createElement(CommitOptionsDropdown, {
        props: { canRevert, canCherryPick, canTag, canEmailPatches },
      }),
  });
}
