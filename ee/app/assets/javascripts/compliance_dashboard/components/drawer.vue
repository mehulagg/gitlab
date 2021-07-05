<script>
import { GlDrawer } from '@gitlab/ui';
import BranchPath from './drawer_sections/branch_path.vue';
import Committers from './drawer_sections/committers.vue';
import Project from './drawer_sections/project.vue';
import Reference from './drawer_sections/reference.vue';
import Reviewers from './drawer_sections/reviewers.vue';

export default {
  components: {
    BranchPath,
    Committers,
    GlDrawer,
    Reference,
    Reviewers,
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
    hasCommitters() {
      return this.mergeRequest.committers.length > 0;
    },
    hasReviewers() {
      return (
        this.mergeRequest.participants.length > 0 ||
        this.mergeRequest.approved_by_users.length > 0 ||
        Boolean(this.mergeRequest.merged_by?.name)
      );
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
    <template #header>
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
      <committers v-if="hasCommitters" :committers="mergeRequest.committers" />
      <reviewers
        v-if="hasReviewers"
        :approvers="mergeRequest.approved_by_users"
        :commenters="mergeRequest.participants"
        :merged-by="mergeRequest.merged_by"
      />
    </template>
  </gl-drawer>
</template>
