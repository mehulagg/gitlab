<script>
import { __ } from '~/locale';

import IssuableShow from '~/issuable_show/components/issuable_show_root.vue';

export default {
  name: 'JiraIssueShow',
  components: {
    IssuableShow,
  },
  data() {
    return {
      isLoading: false,
      jiraIssue: {
        titleHtml: 'My Issue',
        descriptionHtml: 'Make Jira issues look awesome in GitLab',
        author: {
          avatarUrl: '',
          name: 'Tom Quirk',
        },
        createdAt: new Date().toString(),
        updatedAt: new Date().toString(),
        state: 'opened',
      },
    };
  },
  computed: {
    isIssueOpen() {
      return this.jiraIssue.state === 'opened';
    },
    statusIcon() {
      return this.isIssueOpen ? 'issue-open-m' : 'mobile-issue-close';
    },
    statusBadgeClass() {
      return this.isIssueOpen ? 'status-box-open' : 'status-box-issue-closed';
    },
    statusBadgeText() {
      const issueStateLabels = {
        opened: __('Open'),
        closed: __('Closed'),
      };

      return issueStateLabels[this.jiraIssue.state];
    },
  },
};
</script>

<template>
  <issuable-show
    v-if="!isLoading"
    :issuable="jiraIssue"
    :status-icon="statusIcon"
    :status-badge-class="statusBadgeClass"
    :enable-edit="false"
    :enable-autocomplete="true"
  >
    <template #status-badge> {{ statusBadgeText }} </template></issuable-show
  >
</template>
