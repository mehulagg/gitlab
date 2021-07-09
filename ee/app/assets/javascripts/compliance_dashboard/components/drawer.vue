<script>
import { GlDrawer } from '@gitlab/ui';
import BranchPath from './drawer_sections/branch_path.vue';
import Project from './drawer_sections/project.vue';
import Reference from './drawer_sections/reference.vue';

export default {
  components: {
    GlDrawer,
    BranchPath,
    Reference,
    Project,
  },
  props: {
    mergeRequest: {
      type: Object,
      required: true,
    },
    showDrawer: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    hasBranchDetails() {
      return this.mergeRequest.source_branch && this.mergeRequest.target_branch;
    },
  },
  methods: {
    getDrawerHeaderHeight() {
      const wrapperEl = document.querySelector('.content-wrapper');

      if (wrapperEl) {
        return `${wrapperEl.offsetTop}px`;
      }

      return '';
    },
  },
  // We set the drawer's z-index to 252 to clear flash messages that might be displayed in the page
  // and that have a z-index of 251.
  Z_INDEX: 252,
};
</script>
<template>
  <gl-drawer
    :open="showDrawer"
    :header-height="getDrawerHeaderHeight()"
    :z-index="$options.Z_INDEX"
    @close="$emit('close')"
  >
    <template #title>
      <h4 data-testid="dashboard-drawer-title">{{ mergeRequest.title }}</h4>
    </template>
    <template v-if="showDrawer" #default>
      <project
        :avatar-url="mergeRequest.project.avatar_url"
        :compliance-framework="mergeRequest.compliance_management_framework"
        :name="mergeRequest.project.name"
        :url="mergeRequest.project.web_url"
      />
      <reference :path="mergeRequest.path" :reference="mergeRequest.reference" />
      <branch-path
        v-if="hasBranchDetails"
        :source-branch="mergeRequest.source_branch"
        :source-branch-uri="mergeRequest.source_branch_uri"
        :target-branch="mergeRequest.target_branch"
        :target-branch-uri="mergeRequest.target_branch_uri"
      />
    </template>
  </gl-drawer>
</template>
