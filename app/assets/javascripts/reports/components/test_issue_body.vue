<script>
import { GlBadge, GlButton, GlSprintf } from '@gitlab/ui';
import { mapActions } from 'vuex';
import IssueStatusIcon from '~/reports/components/issue_status_icon.vue';

export default {
  name: 'TestIssueBody',
  components: {
    GlBadge,
    GlButton,
    GlSprintf,
    IssueStatusIcon,
  },
  props: {
    issue: {
      type: Object,
      required: true,
    },
  },
  computed: {
    showRecentFailures() {
      return this.issue.recent_failures?.count && this.issue.recent_failures?.base_branch;
    },
  },
  methods: {
    ...mapActions(['openModal']),
  },
};
</script>
<template>
  <div class="gl-display-flex gl-mt-2 gl-mb-2">
    <issue-status-icon :status="issue.status" :status-icon-size="24" class="gl-mr-3" />
    <div data-testid="test-issue-body-description">
      <gl-badge v-if="showRecentFailures" variant="warning" class="gl-mr-2">
        <gl-sprintf
          :message="
            n__(
              'Reports|Failed %{count} time in %{base_branch} in the last 14 days',
              'Reports|Failed %{count} times in %{base_branch} in the last 14 days',
              issue.recent_failures.count,
            )
          "
        >
          <template #count>{{ issue.recent_failures.count }}</template>
          <template #base_branch>{{ issue.recent_failures.base_branch }}</template>
        </gl-sprintf>
      </gl-badge>
      <gl-button
        button-text-classes="gl-white-space-normal! gl-word-break-all gl-text-left"
        variant="link"
        @click="openModal({ issue })"
      >
        {{ issue.name }}
      </gl-button>
    </div>
  </div>
</template>
