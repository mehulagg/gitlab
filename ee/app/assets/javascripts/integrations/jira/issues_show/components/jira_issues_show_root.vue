<script>
import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';

import { fetchIssue } from 'ee/integrations/jira/issues_show/api';
import { issueStates, issueStateLabels } from 'ee/integrations/jira/issues_show/constants';
import Sidebar from 'ee/integrations/jira/issues_show/components/sidebar.vue';
import IssuableShow from '~/issuable_show/components/issuable_show_root.vue';

import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

export default {
  name: 'JiraIssuesShow',
  components: {
    GlAlert,
    GlLink,
    GlSprintf,
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
    statusIcon() {
      return this.isIssueOpen ? 'issue-open-m' : 'mobile-issue-close';
    },
  },
  async mounted() {
    this.issue = convertObjectPropsToCamelCase(await fetchIssue(this.issuesShowPath), {
      deep: true,
    });
    this.isLoading = false;
  },
};
</script>

<template>
  <div>
    <gl-alert
      variant="info"
      :dismissible="false"
      :title="s__('JiraService|This issue is being synced from Jira')"
      class="gl-mt-5 gl-mb-2"
    >
      <gl-sprintf
        :message="
          s__(
            `JiraService|In order to view more details or to make changes to this issue, please visit the issue directly in %{linkStart}Jira%{linkEnd}`,
          )
        "
      >
        <template #link="{ content }">
          <gl-link :href="issue.webUrl" target="_blank">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>
    <issuable-show
      v-if="!isLoading"
      :issuable="issue"
      :enable-edit="false"
      :status-badge-class="statusBadgeClass"
      :status-icon="statusIcon"
    >
      <template #status-badge>{{ statusBadgeText }}</template>

      <template #right-sidebar-items="{ sidebarExpanded }">
        <sidebar :sidebar-expanded="sidebarExpanded" :selected-labels="issue.labels" />
      </template>
    </issuable-show>
  </div>
</template>
