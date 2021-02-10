<script>
import { fetchIssue } from 'ee/integrations/jira/issues_show/api';
import { issueStates, issueStateLabels } from 'ee/integrations/jira/issues_show/constants';
import Sidebar from 'ee/integrations/jira/issues_show/components/sidebar.vue';
import IssuableShow from '~/issuable_show/components/issuable_show_root.vue';

import { transformJiraIssue } from '../../utils';

export default {
  name: 'JiraIssuesShow',
  components: {
    IssuableShow,
    Sidebar,
  },
  inject: {
    issuesShowPath: {
      default: '',
    },
  },
  data() {
    return {
      isLoading: true,
      issue: {},
    };
  },
  computed: {
    isIssueOpen() {
      return this.issue.state === issueStates.OPENED;
    },
    statusBadgeClass() {
      return this.isIssueOpen ? 'status-box-open' : 'status-box-issue-closed';
    },
    statusBadgeText() {
      return issueStateLabels[this.issue.state];
    },
  },
  async mounted() {
    this.issue = transformJiraIssue(await fetchIssue(this.issuesShowPath), {
      deep: true,
    });
    this.isLoading = false;
  },
};
</script>

<template>
  <div>
    <issuable-show
      v-if="!isLoading"
      :issuable="issue"
      :enable-edit="false"
      :status-badge-class="statusBadgeClass"
    >
      <template #status-badge>{{ statusBadgeText }}</template>

      <template #right-sidebar-items="{ sidebarExpanded }">
        <sidebar :sidebar-expanded="sidebarExpanded" :selected-labels="issue.labels" />
      </template>
    </issuable-show>
  </div>
</template>
