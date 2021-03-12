<script>
import { GlDropdown, GlDropdownItem, GlDropdownDivider, GlDropdownSectionHeader } from '@gitlab/ui';
import { OPEN_REVERT_MODAL, OPEN_CHERRY_PICK_MODAL } from '../constants';
import eventHub from '../event_hub';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
    GlDropdownDivider,
    GlDropdownSectionHeader,
  },
  inject: {
    newProjectTagPath: {
      default: '',
    },
    emailPatchesPath: {
      default: '',
    },
    plainDiffPath: {
      default: '',
    },
  },
  props: {
    canRevert: {
      type: Boolean,
      required: true,
    },
    canCherryPick: {
      type: Boolean,
      required: true,
    },
    canTag: {
      type: Boolean,
      required: true,
    },
    canEmailPatches: {
      type: Boolean,
      required: true,
    },
  },
  methods: {
    showModal(modalId) {
      eventHub.$emit(modalId);
    },
  },
  openRevertModal: OPEN_REVERT_MODAL,
  openCherryPickModal: OPEN_CHERRY_PICK_MODAL,
};
</script>

<template>
  <gl-dropdown :text="__('Options')" :right="true">
    <gl-dropdown-item v-if="canRevert" @click="showModal($options.openRevertModal)">
      {{ __('Revert') }}
    </gl-dropdown-item>
    <gl-dropdown-item v-if="canCherryPick" @click="showModal($options.openCherryPickModal)">
      {{ __('Cherry-pick') }}
    </gl-dropdown-item>
    <gl-dropdown-item v-if="canTag" :href="newProjectTagPath">
      {{ s__('CreateTag|Tag') }}
    </gl-dropdown-item>
    <gl-dropdown-divider />
    <gl-dropdown-section-header>
      {{ __('Download') }}
    </gl-dropdown-section-header>
    <gl-dropdown-item v-if="canEmailPatches" :href="emailPatchesPath">
      {{ s__('DownloadCommit|Email Patches') }}
    </gl-dropdown-item>
    <gl-dropdown-item :href="plainDiffPath">
      {{ s__('DownloadCommit|Plain Diff') }}
    </gl-dropdown-item>
  </gl-dropdown>
</template>
