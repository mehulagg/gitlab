<script>
import { GlAlert, GlSprintf, GlLink, GlBadge } from '@gitlab/ui';
import { fetchIssue } from 'ee/integrations/jira/issues_show/api';
import JiraIssueSidebar from 'ee/integrations/jira/issues_show/components/sidebar/jira_issues_sidebar_root.vue';
import { issueStates, issueStateLabels } from 'ee/integrations/jira/issues_show/constants';
import DesignNote from '~/design_management/components/design_notes/design_note.vue';
import IssuableShow from '~/issuable_show/components/issuable_show_root.vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

function jiraCommentToNote(comment) {
  return {
    id: '1',
    body: comment.note,
    bodyHtml: comment.note,
    createdAt: comment.created_at,
    author: {
      webUrl: '',
      avatarUrl: '',
      username: '',
      id: '',
      name: comment.name,
    },
  };
}

export default {
  name: 'JiraIssuesShow',
  components: {
    GlAlert,
    GlSprintf,
    GlLink,
    GlBadge,
    IssuableShow,
    JiraIssueSidebar,
    DesignNote,
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
    this.issue.comments = [
      {
        name: 'Tom Quirk',
        web_url: 'https://google.com',
        avatar_url: 'https://google.com',
        note: 'Great idea',
        created_at: new Date(),
        updated_at: new Date(),
      },
      {
        name: 'Tom Quirk',
        web_url: 'https://google.com',
        avatar_url: 'https://google.com',
        note: 'Thanks!',
        created_at: new Date(),
        updated_at: new Date(),
      },
    ].map(jiraCommentToNote);
  },
};
</script>

<template>
  <div class="gl-mt-5">
    <gl-alert
      variant="info"
      :dismissible="false"
      :title="s__('JiraService|This issue is synchronized with Jira')"
      class="gl-mb-2"
    >
      <gl-sprintf
        :message="
          s__(
            `JiraService|Not all data may be displayed here. To view more details or make changes to this issue, go to %{linkStart}Jira%{linkEnd}.`,
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
        <jira-issue-sidebar :sidebar-expanded="sidebarExpanded" :issue="issue" />
      </template>

      <template #discussion>
        <design-note
          v-for="(comment, idx) in issue.comments"
          :key="`jira-comment-${idx}`"
          class-override="note note-wrapper"
          :note="comment"
          :show-reply-button="false"
          :editable="false"
        >
          <template #badges>
            <gl-badge>{{ __('Jira user') }}</gl-badge>
          </template>
        </design-note>
      </template>
    </issuable-show>
  </div>
</template>
