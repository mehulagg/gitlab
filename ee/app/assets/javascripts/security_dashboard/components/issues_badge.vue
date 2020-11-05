<script>
import { GlIcon, GlPopover, GlBadge } from '@gitlab/ui';
import IssueLink from 'ee/vulnerabilities/components/issue_link.vue';
import { n__ } from '~/locale';

export default {
  components: {
    GlIcon,
    GlBadge,
    GlPopover,
    IssueLink,
  },
  props: {
    issues: {
      type: Array,
      required: true,
    },
  },
  computed: {
    numberOfIssues() {
      return this.issues.length;
    },
    popoverTitle() {
      return n__('1 Issue', '%d Issues', this.numberOfIssues);
    },
    issueBadgeEl() {
      return () => this.$refs.issueBadge?.$el;
    },
  },
};
</script>

<template>
  <div class="gl-display-inline-block">
    <gl-badge ref="issueBadge" class="gl-px-3">
      <gl-icon name="issues" class="gl-mr-2" />
      {{ numberOfIssues }}
    </gl-badge>
    <gl-popover ref="popover" :target="issueBadgeEl" triggers="hover" placement="top">
      <template #title>
        {{ popoverTitle }}
      </template>
      <div v-for="{ issue } in issues" :key="issue.iid">
        <issue-link :issue="issue" />
      </div>
    </gl-popover>
  </div>
</template>
