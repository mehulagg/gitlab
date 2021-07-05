<script>
import { __ } from '~/locale';
import BranchDetails from '../shared/branch_details.vue';
import DrawerSectionHeader from '../shared/drawer_section_header.vue';

export default {
  components: {
    BranchDetails,
    DrawerSectionHeader,
  },
  props: {
    sourceBranch: {
      type: String,
      required: false,
      default: '',
    },
    sourceBranchUri: {
      type: String,
      required: false,
      default: '',
    },
    targetBranch: {
      type: String,
      required: false,
      default: '',
    },
    targetBranchUri: {
      type: String,
      required: false,
      default: '',
    },
  },
  i18n: {
    header: __('Path'),
  },
};
</script>
<template>
  <div>
    <drawer-section-header>{{ $options.i18n.header }}</drawer-section-header>
    <branch-details
      class="gl-justify-content-start gl-text-gray-500"
      :source-branch="{
        name: sourceBranch,
        uri: sourceBranchUri,
      }"
      :target-branch="{
        name: targetBranch,
        uri: targetBranchUri,
      }"
    />
  </div>
</template>
